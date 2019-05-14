"""
Test suite for the jarombek-com vpc infrastructure.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 5/4/2019
"""

import masterTestFuncs as Test
from apps.jarombekcom import jarombekTestFuncs as Func

tests = [
    lambda: Test.test(
        Func.jarombek_com_vpc_exists,
        "Determine if the jarombek.com VPC Exists"
    ),
    lambda: Test.test(
        Func.jarombek_com_vpc_configured,
        "Determine if the jarombek.com VPC is Configured Properly"
    ),
    lambda: Test.test(
        Func.jarombek_com_internet_gateway_exists,
        "Determine if the jarombek.com Internet Gateway Exists"
    ),
    lambda: Test.test(
        Func.jarombek_com_network_acl_exists,
        "Determine if the jarombek.com Network ACL Exists"
    ),
    lambda: Test.test(
        Func.jarombek_com_dns_resolver_exists,
        "Determine if the jarombek.com DNS Resolver Exists"
    ),
    lambda: Test.test(
        Func.jarombek_com_sg_valid,
        "Determine if the jarombek.com VPC Security Group is Valid"
    ),
    lambda: Test.test(
        Func.jarombek_com_yeezus_public_subnet_exists,
        "Determine if the jarombek-com-yeezus Public Subnet Exists"
    ),
    lambda: Test.test(
        Func.jarombek_com_yeezus_public_subnet_configured,
        "Determine if the jarombek-com-yeezus Public Subnet is Properly Configured"
    ),
    lambda: Test.test(
        Func.jarombek_com_yeezus_public_subnet_rt_configured,
        "Determine if the jarombek-com-yeezus Public Subnet Route Table is Properly Configured"
    ),
    lambda: Test.test(
        Func.jarombek_com_yandhi_public_subnet_exists,
        "Determine if the jarombek-com-yandhi Public Subnet Exists"
    ),
    lambda: Test.test(
        Func.jarombek_com_yandhi_public_subnet_configured,
        "Determine if the jarombek-com-yandhi Public Subnet is Properly Configured"
    ),
    lambda: Test.test(
        Func.jarombek_com_yandhi_public_subnet_rt_configured,
        "Determine if the jarombek-com-yandhi Public Subnet Route Table is Properly Configured"
    ),
    lambda: Test.test(
        Func.jarombek_com_red_private_subnet_exists,
        "Determine if the jarombek-com-red Private Subnet Exists"
    ),
    lambda: Test.test(
        Func.jarombek_com_red_private_subnet_configured,
        "Determine if the jarombek-com-red Private Subnet is Properly Configured"
    ),
    lambda: Test.test(
        Func.jarombek_com_reputation_private_subnet_exists,
        "Determine if the jarombek-com-reputation Private Subnet Exists"
    ),
    lambda: Test.test(
        Func.jarombek_com_reputation_private_subnet_configured,
        "Determine if the jarombek-com-reputation Private Subnet is Properly Configured"
    )
]


def jarombek_test_suite() -> bool:
    """
    Execute all the tests related to the jarombek-com vpc infrastructure
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Jarombek VPC Test Suite")