
# ROMULUS-N Python Implementation

# Copyright 2020:
#     Thomas Peyrin <thomas.peyrin@gmail.com>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.

from SKINNY_128_384_plus import *
import math

# ####################################################################
# # ROMULUS-N
# ####################################################################

# # ROMULUS-N
T_LENGTH = 16
COUNTER_LENGTH = 7
MEMBER_MASK = 0

DEBUG = 1

def increase_counter(counter):
    if counter[COUNTER_LENGTH - 1] & 0x80 != 0: mask = 0x95
    else: mask = 0
    for i in reversed(range(1, COUNTER_LENGTH)):
        counter[i] = ((counter[i] << 1) & 0xfe) ^ (counter[i - 1] >> 7)
    counter[0] = ((counter[0] << 1) & 0xfe) ^ mask
    # print("".join("{:02X}".format(_) for _ in counter))
    return counter


def parse(L_in,x): 
    L_out = []
    cursor = 0
    while len(L_in) - cursor >= x:
       L_out.extend([L_in[cursor:cursor+x]])
       cursor = cursor + x 
    if len(L_in) - cursor > 0:
       L_out.extend([L_in[cursor:]])
    if L_in == []:
        L_out = [[]]
    L_out.insert(0,[])
    return L_out


def pad(x, pad_length):
    if len(x) == 0:
        return [0] * pad_length
    if len(x) == pad_length:
        return x[:]
    y = x[:]
    for _ in range(pad_length - len(x) - 1):
        y.append(0)
    y.append(len(x))
    return y


def G(A):
    return [(x >> 1) ^ ((x ^ x << 7) & 0x80) for x in A]


def rho(S, M):
    G_S = G(S)
    C = [M[i] ^ G_S[i] for i in range(16)]
    S_prime = [S[i] ^ M[i] for i in range(16)]
    stringS = "".join(["{:02X}".format(_) for _ in S_prime])
    return S_prime, C


def rho_inv(S, C):
    G_S = G(S)
    M = [C[i] ^ G_S[i] for i in range(16)]
    S_prime = [S[i] ^ M[i] for i in range(16)]
    return S_prime, M


def tk_encoding(counter, b, t, k):
    return counter + [b ^ MEMBER_MASK] + [0] * 8 + t + k


# function that implements the AE encryption
# inputs: M the message, A the associated data, N the nonce, K the key
# outputs: C the ciphertext (the last 16 bytes representing the authentication tag)
def crypto_aead_encrypt(M, A, N, K):
    S = [0] * 16
    counter = [1] + [0] * (COUNTER_LENGTH - 1)    
    A_parsed = parse(A,16)
    a = len(A_parsed)-1
    if len(A_parsed[a]) < 16: wa = 26 
    else: wa = 24
    A_parsed[a] = pad(A_parsed[a],16)
    for i in range(1,math.floor(a/2)+1):
        S, _ = rho(S, A_parsed[2*i-1])
        stringS = "".join("{:02X}".format(x) for x in S)
        print(f"RHO Output {stringS}")
        # print(f"Rho Call AD Block {2*i +1} ".join(str(stringS)))
        counter = increase_counter(counter)
        stringS = "".join("{:02X}".format(x) for x in tk_encoding(counter, 8, A_parsed[2*i], K))
        print(f"Counter Output {stringS}")
        # print("".join("{:02X}".format(_) for _ in tk_encoding(counter, 8, A_parsed[2*i], K)))
        S = skinny_enc(S, tk_encoding(counter, 8, A_parsed[2*i], K))
        stringS = "".join("{:02X}".format(_) for _ in S)
        print(f"TBC Output {stringS}")
        counter = increase_counter(counter)

    if a%2==0: V = [0]*16  
    else: 
        V = A_parsed[a]
        counter = increase_counter(counter)
    S, _ = rho(S, V)
    stringS = "".join("{:02X}".format(x) for x in S)
    print(f"RHO Output {stringS}")
    stringS = "".join("{:02X}".format(x) for x in tk_encoding(counter, wa, N, K))
    print(f"Counter Output {stringS}")
    S = skinny_enc(S, tk_encoding(counter, wa, N, K))
    
    counter = [1] + [0] * (COUNTER_LENGTH - 1)
    C = []
    M_parsed = parse(M,16)
    m = len(M_parsed)-1
    if len(M_parsed[m]) < 16: wm = 21  
    else: wm = 20
    for i in range(1,m):
        S, x = rho(S, M_parsed[i])
        stringS = "".join(["{:02X}".format(_) for _ in S])
        print(f"RHO Output {stringS}")
        # if DEBUG==1: print(f"CipherText Output {i} \n")
        counter = increase_counter(counter)
        stringS = "".join("{:02X}".format(x) for x in tk_encoding(counter, 4, N, K))
        print(f"Counter Output {stringS}")
        C.extend(x)        
        S = skinny_enc(S, tk_encoding(counter, 4, N, K))
        stringS = "".join("{:02X}".format(_) for _ in S)
        print(f"TBC Output {stringS}")

    M_prime = pad(M_parsed[m],16)
    S, x = rho(S, M_prime)
    print("".join(["{:02X}".format(_) for _ in S]))
    counter = increase_counter(counter)
    C.extend(x[:len(M_parsed[m])])        
    S = skinny_enc(S, tk_encoding(counter, wm, N, K))
    S, T = rho(S, [0] * 16)
    C.extend(T)
    return C    
        

# function that implements the AE decryption
# inputs: C the ciphertext (the last 16 bytes representing the authentication tag), A the associated data, N the nonce, K the key
# outputs: (0,M) with M the message if the tag is verified, returns (-1,[]) otherwise
def crypto_aead_decrypt(C, A, N, K):
    S = [0] * 16
    counter = [1] + [0] * (COUNTER_LENGTH - 1)
    A_parsed = parse(A,16)
    a = len(A_parsed)-1
    if len(A_parsed[a]) < 16: wa = 26 
    else: wa = 24
    A_parsed[a] = pad(A_parsed[a],16)
    for i in range(1,math.floor(a/2)+1):
        S, _ = rho(S, A_parsed[2*i-1])
        counter = increase_counter(counter)
        S = skinny_enc(S, tk_encoding(counter, 8, A_parsed[2*i], K))
        counter = increase_counter(counter)

    if a%2==0: V = [0]*16  
    else: 
        V = A_parsed[a]
        counter = increase_counter(counter)
    S, _ = rho(S, V)
    S = skinny_enc(S, tk_encoding(counter, wa, N, K))
    
    counter = [1] + [0] * (COUNTER_LENGTH - 1)
    M = []
    T = C[-16:]
    C[-16:] = []
    C_parsed = parse(C,16)
    c = len(C_parsed)-1
    if len(C_parsed[c]) < 16: wc = 21  
    else: wc = 20
    for i in range(1,c):
        S, x = rho_inv(S, C_parsed[i])
        counter = increase_counter(counter)
        M.extend(x)        
        S = skinny_enc(S, tk_encoding(counter, 4, N, K))

    S_tilde = G(S[:])
    l = len(C_parsed[c])
    S_tilde = [0]*l + S_tilde[l-16:]
    C_prime = pad(C_parsed[c],16)
    for i in range(16):
        C_prime[i] = C_prime[i] ^ S_tilde[i] 
    S, x = rho_inv(S, C_prime)
    counter = increase_counter(counter)
    M.extend(x[:len(C_parsed[c])])  
    S = skinny_enc(S, tk_encoding(counter, wc, N, K))    
    S, T_computed = rho(S, [0] * 16)
    compare = 0
    for i in range(16):
        compare |= (T[i] ^ T_computed[i])

    if compare != 0:
        return -1, []
    else:
        return 0, M

# x"0C0D0E0F", x"08090A0B", x"04050607", x"00010203"
ptext = [0x0c, 0x0d, 0x03, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03,0x0c, 0x0d, 0x03, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03 ]
associated_data = [0x0c, 0x0d, 0x03, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03,0x0c, 0x0d, 0x03, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03 ]
npub = [0x0c, 0x0d, 0x03, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03]
key = [0x0c, 0x0d, 0x03, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03]
crypto_aead_encrypt(ptext, associated_data, npub, key)