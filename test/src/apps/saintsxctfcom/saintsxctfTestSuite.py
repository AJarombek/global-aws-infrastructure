"""
Test suite for the saints-xctf-com vpc infrastructure.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

from src import masterTestFuncs as Test
from src.apps.saintsxctfcom import saintsxctfTestFuncs as Func

tests = [
    lambda: Test.test(
        Func.saintsxctf_com_vpc_exists,
        "Determine if the saintsxctf.com VPC Exists"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_vpc_configured,
        "Determine if the saintsxctf.com VPC is Configured Properly"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_internet_gateway_exists,
        "Determine if the saintsxctf.com Internet Gateway Exists"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_network_acl_exists,
        "Determine if the saintsxctf.com Network ACL Exists"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_dns_resolver_exists,
        "Determine if the saintsxctf.com DNS Resolver Exists"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_sg_valid,
        "Determine if the saintsxctf.com VPC Security Group is Valid"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_lisag_public_subnet_exists,
        "Determine if the saints-xctf-com-lisag Public Subnet Exists"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_lisag_public_subnet_configured,
        "Determine if the saints-xctf-com-lisag Public Subnet is Properly Configured"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_lisag_public_subnet_rt_configured,
        "Determine if the saints-xctf-com-lisag Public Subnet Route Table is Properly Configured"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_megank_public_subnet_exists,
        "Determine if the saints-xctf-com-megank Public Subnet Exists"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_megank_public_subnet_configured,
        "Determine if the saints-xctf-com-megank Public Subnet is Properly Configured"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_megank_public_subnet_rt_configured,
        "Determine if the saints-xctf-com-megank Public Subnet Route Table is Properly Configured"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_cassiah_private_subnet_exists,
        "Determine if the saints-xctf-com-cassiah Private Subnet Exists"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_cassiah_private_subnet_configured,
        "Determine if the saints-xctf-com-cassiah Private Subnet is Properly Configured"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_carolined_private_subnet_exists,
        "Determine if the saints-xctf-com-carolined Private Subnet Exists"
    ),
    lambda: Test.test(
        Func.saintsxctf_com_carolined_private_subnet_configured,
        "Determine if the saints-xctf-com-carolined Private Subnet is Properly Configured"
    )
]


def saints_xctf_test_suite() -> bool:
    """
    Execute all the tests related to the saints-xctf-com vpc infrastructure
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "SaintsXCTF VPC Test Suite")

print(saints_xctf_test_suite())