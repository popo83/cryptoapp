"""
Script per crittografia del testo
Include: AES, RSA, Hashing
"""

from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
import base64
import hashlib
import os

# ============================================
# AES - Crittografia Simmetrica
# ============================================

def genera_chiave_aes():
    """Genera una chiave AES casuale"""
    return Fernet.generate_key()

def crittografa_aes(testo, chiave):
    """Crittografa un testo con AES"""
    f = Fernet(chiave)
    return f.encrypt(testo.encode())

def decrittografa_aes(testo_criptato, chiave):
    """Decrittografa un testo con AES"""
    f = Fernet(chiave)
    return f.decrypt(testo_criptato).decode()

# ============================================
# RSA - Crittografia Asimmetrica
# ============================================

def genera_keypair_rsa():
    """Genera una coppia di chiavi RSA"""
    chiave_privata = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend()
    )
    chiave_pubblica = chiave_privata.public_key()
    return chiave_privata, chiave_pubblica

def serializza_chiave_pubblica(chiave_pubblica):
    """Serializza la chiave pubblica in formato PEM"""
    return chiave_pubblica.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )

def crittografa_rsa(testo, chiave_pubblica):
    """Crittografa un testo con RSA"""
    return chiave_pubblica.encrypt(
        testo.encode(),
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )

def decrittografa_rsa(testo_criptato, chiave_privata):
    """Decrittografa un testo con RSA"""
    return chiave_privata.decrypt(
        testo_criptato,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    ).decode()

# ============================================
# Hashing
# ============================================

def genera_hash_sha256(testo):
    """Genera un hash SHA256 del testo"""
    return hashlib.sha256(testo.encode()).hexdigest()

def genera_hash_sha512(testo):
    """Genera un hash SHA512 del testo"""
    return hashlib.sha512(testo.encode()).hexdigest()

def genera_hash_blake2b(testo):
    """Genera un hash Blake2b (più veloce e sicuro)"""
    return hashlib.blake2b(testo.encode()).hexdigest()

# ============================================
# Esempio di utilizzo
# ============================================

if __name__ == "__main__":
    print("=== Crittografia AES ===")
    chiave_aes = genera_chiave_aes()
    print(f"Chiave AES: {chiave_aes}")
    
    messaggio = "Ciao, questo è un messaggio segreto!"
    crittato = crittografa_aes(messaggio, chiave_aes)
    print(f"Crittografato: {crittato}")
    
    decrittato = decrittografa_aes(crittato, chiave_aes)
    print(f"Decrittografato: {decrittato}")
    
    print("\n=== Crittografia RSA ===")
    privata, pubblica = genera_keypair_rsa()
    print("Keypair RSA generato!")
    
    crittato_rsa = crittografa_rsa(messaggio, pubblica)
    print(f"Crittografato RSA: {base64.b64encode(crittato_rsa).decode()}")
    
    decrittato_rsa = decrittografa_rsa(crittato_rsa, privata)
    print(f"Decrittografato RSA: {decrittato_rsa}")
    
    print("\n=== Hashing ===")
    print(f"SHA256: {genera_hash_sha256(messaggio)}")
    print(f"SHA512: {genera_hash_sha512(messaggio)}")
    print(f"BLAKE2b: {genera_hash_blake2b(messaggio)}")
