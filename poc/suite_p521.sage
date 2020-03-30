#!/usr/bin/sage
# vim: syntax=python

import hashlib
import sys
from hash_to_field import expand_message_xmd
try:
    from sagelib.h2c_suite import BasicH2CSuiteDef, BasicH2CSuite
    from sagelib.svdw_generic import GenericSvdW
    from sagelib.sswu_generic import GenericSSWU
    from sagelib.suite_p256 import _test_suite
except ImportError:
    sys.exit("Error loading preprocessed sage files. Try running `make clean pyfiles`")

p = 2^521 - 1
F = GF(p)
A = F(-3)
B = F(0x51953eb9618e1c9a1f929a21a0b68540eea2da725b99b315f3b8b489918ef109e156193951ec7e937b1652c0bd3bb1bf073573df883d2c34f1ef451fd46b503f00)

def p521_sswu(suite_name, is_ro):
    return BasicH2CSuiteDef("P521", F, A, B, expand_message_xmd, hashlib.sha512, 96, GenericSSWU, 1, 256, is_ro, "%sTESTGEN" % suite_name)

def p521_svdw(suite_name, is_ro):
    return p521_sswu(suite_name, is_ro)._replace(MapT=GenericSvdW)

suite_name = "P521_XMD:SHA-512_SSWU_RO_"
p521_sswu_ro = BasicH2CSuite(suite_name,p521_sswu(suite_name, True))

suite_name = "P521_XMD:SHA-512_SVDW_RO_"
p521_svdw_ro = BasicH2CSuite(suite_name,p521_svdw(suite_name, True))

suite_name = "P521_XMD:SHA-512_SSWU_NU_"
p521_sswu_nu = BasicH2CSuite(suite_name,p521_sswu(suite_name, False))

suite_name = "P521_XMD:SHA-512_SVDW_NU_"
p521_svdw_nu = BasicH2CSuite(suite_name,p521_svdw(suite_name, False))

assert p521_sswu_ro.m2c.Z == p521_sswu_nu.m2c.Z == -4
assert p521_svdw_ro.m2c.Z == p521_svdw_nu.m2c.Z == 1

p521_order = 0x1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa51868783bf2f966b7fcc0148f709a5d03bb5c9b8899c47aebb6fb71e91386409

def test_suite_p521():
    _test_suite(p521_sswu_ro, p521_order)
    _test_suite(p521_svdw_ro, p521_order)
    _test_suite(p521_sswu_nu, p521_order)
    _test_suite(p521_svdw_nu, p521_order)

if __name__ == "__main__":
    test_suite_p521()