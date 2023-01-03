
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
    N_value = "".join("{:02X}".format(x) for x in N)
    K_value = "".join("{:02X}".format(x) for x in K)
    forlooprangea = math.floor(a/2) + 1
    print(f"Nonce Value {N_value}")
    print(f"Key Value {K_value}")
    print(f"edge of loop for a {forlooprangea}")
    print(f"Length of a {a}")
    for i in range(1,math.floor(a/2)+1):
        stringS = "".join("{:02X}".format(x) for x in tk_encoding(counter, 8, A_parsed[2*i-1], K))
        # print(f"Tweakey Output before RHO {stringS}")
        S, _ = rho(S, A_parsed[2*i-1])
        stringS = "".join("{:02X}".format(x) for x in S)
        print(f"RHO Output {stringS}")
        # print(f"Rho Call AD Block {2*i +1} ".join(str(stringS)))
        counter = increase_counter(counter)
        stringS = "".join("{:02X}".format(x) for x in tk_encoding(counter, 8, A_parsed[2*i], K))
        print(f"Tweakey Output after RHO {stringS}")
        # print("".join("{:02X}".format(_) for _ in tk_encoding(counter, 8, A_parsed[2*i], K)))
        S = skinny_enc(S, tk_encoding(counter, 8, A_parsed[2*i], K))
        stringS = "".join("{:02X}".format(_) for _ in S)
        print(f"TBC Output {stringS}")
        counter = increase_counter(counter)

    if a%2==0: V = [0]*16  
    else: 
        V = A_parsed[a]
        counter = increase_counter(counter)
        stringS = "".join("{:02X}".format(x) for x in counter)
        print(f"Counter Value for last block of A {stringS}")
    S, _ = rho(S, V)
    stringS = "".join("{:02X}".format(x) for x in S)
    print(f"RHO Output {stringS}")
    stringS = "".join("{:02X}".format(x) for x in tk_encoding(counter, wa, N, K))
    print(f"Tweakey Output after Rho {stringS}")
    S = skinny_enc(S, tk_encoding(counter, wa, N, K))
    stringS = "".join("{:02X}".format(x) for x in S)
    print(f"State after Last AD N {stringS}")
    print(f"encoding wa {wa}")
    counter = [1] + [0] * (COUNTER_LENGTH - 1)
    C = []
    M_parsed = parse(M,16)
    m = len(M_parsed)-1
    if len(M_parsed[m]) < 16: wm = 21  
    else: wm = 20
    for i in range(1,m):
        S, x = rho(S, M_parsed[i])
        stringS = "".join(["{:02X}".format(_) for _ in S])
        print(f"RHO Output {i} {stringS}")
        # if DEBUG==1: print(f"CipherText Output {i} \n")
        counter = increase_counter(counter)
        stringS = "".join("{:02X}".format(_) for _ in tk_encoding(counter, 4, N, K))
        print(f"Counter Output {stringS}")
        C.extend(x)      
        stringS = "".join("{:02X}".format(_) for _ in x)
        print(f"CipherText Output {i} {stringS}")  
        S = skinny_enc(S, tk_encoding(counter, 4, N, K))
        stringS = "".join("{:02X}".format(_) for _ in S)
        print(f"TBC Output {stringS}")

    M_prime = pad(M_parsed[m],16)
    # print("".join(["{:02X}".format(_) for _ in M_prime]))
    # print("".join(["{:02X}".format(_) for _ in M_parsed[m]]))
    S, x = rho(S, M_prime)
    print("".join(["{:02X}".format(_) for _ in S]))
    counter = increase_counter(counter)
    C.extend(x[:len(M_parsed[m])])    
    CipherTextVal = "".join(["{:02X}".format(_) for _ in C])
    print(f"Cipher Text Value: {CipherTextVal}")
    # print("".join(["{:02X}".format(_) for _ in tk_encoding(counter, wm, N, K)]))       
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
# Big Endian
ptext = [0x0c, 0x0d, 0x0e, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03,0x0c, 0x0d, 0x0e, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03 ]
associated_data = [0x0c, 0x0d, 0x0e, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03,0x0c, 0x0d, 0x0e, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03 ]
npub = [0x0c, 0x0d, 0x0e, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03]
key = [0x0c, 0x0d, 0x0e, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03]
# CipherText = crypto_aead_encrypt(ptext, associated_data, npub, key)
# print(f"Cipher Text Output {''.join(['{:02X}'.format(_) for _ in CipherText])} ")
# Little Endian
# ptext = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0d, 0x0e, 0x0F, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0d, 0x0e, 0x0F ]
# associated_data = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0d, 0x0e, 0x0F, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0d, 0x0e, 0x0F ]
# npub = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0d, 0x0e, 0x0F]
# key = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0d, 0x0e, 0x0F]
# crypto_aead_encrypt(ptext, associated_data, npub, key)
tb_key=[0x83,0x17,0x21,0x3f,0x6f,0x94,0x18,0xfc,0xac,0x2b,0xb0,0xd6,0xd0,0x04,0x22,0x29]
tb_key_endian = [0x92,0x22,0x40,0x0d,0x6d,0x0b,0xb2,0xca,0xcf,0x81,0x49,0xf6,0xf3,0x12,0x71,0x38]
tb_key_end=[0x3f,0x21,0x17,0x83, 0xfc, 0x18,0x94,0x6f, 0xd6,0xb0,0x2b,0xac, 0x29,0x22,0x04,0xd0]
tb_key_rev = [0x94,0x44,0x20,0x0b,0x6b,0x0d,0xd4,0x35,0x3f,0x18,0x29,0xf6,0xfc,0x84,0xe8,0xc1]
tb_key_end_rev = [0x0b,0x20,0x44,0x94,0x35,0xd4,0x0d,0x6b,0xf6,0x29,0x18,0x3f,0xc1,0xe8,0x84,0xfc]
tb_key_other = [0xd0,0x04,0x22,0x29,0xac,0x2b,0xb0,0xd6,0x6f,0x94,0x18,0xfc,0x83,0x17,0x21,0x3f]
tb_key_other_rev = [0x94,0x44,0x20,0x0b,0x6b,0x0d,0xd4,0x35,0x3f,0x18,0x29,0xf6,0xfc,0x84,0xe8,0xc1]
tb_ptext = [0x00]*16
tb_npub = [0xcd,0x56,0x0a,0xa1,0x5c,0xbb,0x42,0xea,0x21,0x0a,0x52,0x6c,0x7f,0x01,0xe4,0x6f]
tb_npub_endian = [0xf6,0x4e,0x10,0xf7,0xc6,0x25,0xa0,0x12,0xae,0x24,0xbb,0xc5,0x1a,0xa0,0x65,0xdc]
tb_npub_end = [0xa1,0x0a,0x56,0xcd, 0xea,0x42,0xbb,0x5c, 0x6c,0x52,0x0a,0x21, 0x6f,0xe4,0x01,0x7f]
tb_npub_rev = [0xf6,0x27,0x80,0xfe,0x36,0x4a,0x50,0x84,0x57,0x42,0xdd,0x3a,0x85,0x50,0x6a,0xb3]
tb_npub_end_rev = [0xfe,0x80,0x27,0xf6,0x84,0x50,0x4a,0x36,0x3a,0xdd,0x42,0x57,0xb3,0x6a,0x50,0x85]
tb_npub_other = [0x7f,0x01,0xe4,0x6f,0x21,0x0a,0x52,0x6c,0x5c,0xbb,0x42,0xea,0xcd,0x56,0x0a,0xa1]
tb_npub_other_rev = [0xf6,0x27,0x80,0xfe,0x36,0x4a,0x50,0x84,0x57,0x42,0xdd,0x3a,0x85,0x50,0x6a,0xb3]
tb_ad = [0x00]*16
tb_ad_other = [0xd6,0x00,0x00,0x10]
ptext = [0x0c, 0x0d, 0x0e, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03,0x0c, 0x0d, 0x0e, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03 ]
npub = [0x0c, 0x0d, 0x0e, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03]
key = [0x0c, 0x0d, 0x0e, 0x0F, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03]
# CipherText = crypto_aead_encrypt(ptext, [], npub, key)
# print(f"\n\n\nWith No Associated Data\nCipher Text Output {''.join(['{:02X}'.format(_) for _ in CipherText])} ")
CipherText = crypto_aead_encrypt([], tb_ad_other, tb_npub, tb_key)
print(f"\nWith No Message\n\n\nWith No Associated Data\nTag Output {''.join(['{:02X}'.format(_) for _ in CipherText])} ")