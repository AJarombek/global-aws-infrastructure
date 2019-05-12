"""
Test suite for the root infrastructure of my AWS account.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

from src import masterTestFuncs as Test
from src.root import rootTestFuncs as Func

tests = [
    lambda: Test.test(
        Func.resources_vpc_exists,
        "Determine if the Resources VPC Exists"
    ),
    lambda: Test.test(
        Func.resources_vpc_configured,
        "Determine if the Resources VPC is Configured Properly"
    ),
    lambda: Test.test(
        Func.resources_internet_gateway_exists,
        "Determine if the Resources Internet Gateway Exists"
    ),
    lambda: Test.test(
        Func.resources_network_acl_exists,
        "Determine if the Resources Network ACL Exists"
    ),
    lambda: Test.test(
        Func.resources_dns_resolver_exists,
        "Determine if the Resources DNS Resolver Exists"
    ),
    lambda: Test.test(
        Func.resources_sg_valid,
        "Determine if the Resources VPC Security Group is Valid"
    ),
    lambda: Test.test(
        Func.resources_public_subnet_exists,
        "Determine if the Resources Public Subnet Exists"
    ),
    lambda: Test.test(
        Func.resources_public_subnet_configured,
        "Determine if the Resources VPC Public Subnet is Properly Configured"
    ),
    lambda: Test.test(
        Func.resources_public_subnet_rt_configured,
        "Determine if the Resources Public Subnet Route Table is Properly Configured"
    ),
    lambda: Test.test(
        Func.resources_private_subnet_exists,
        "Determine if the Resources Private Subnet Exists"
    ),
    lambda: Test.test(
        Func.resources_private_subnet_configured,
        "Determine if the Resources Private Subnet is Properly Configured"
    ),
    lambda: Test.test(
        Func.sandbox_vpc_exists,
        "Determine if the Sandbox VPC Exists"
    ),
    lambda: Test.test(
        Func.sandbox_vpc_configured,
        "Determine if the Sandbox VPC is Configured Properly"
    ),
    lambda: Test.test(
        Func.sandbox_internet_gateway_exists,
        "Determine if the Sandbox Internet Gateway Exists"
    ),
    lambda: Test.test(
        Func.sandbox_network_acl_exists,
        "Determine if the Sandbox Network ACL Exists"
    ),
    lambda: Test.test(
        Func.sandbox_dns_resolver_exists,
        "Determine if the Sandbox DNS Resolver Exists"
    ),
    lambda: Test.test(
        Func.sandbox_sg_valid,
        "Determine if the Sandbox VPC Security Group is Valid"
    ),
    lambda: Test.test(
        Func.sandbox_fearless_public_subnet_exists,
        "Determine if the Sandbox 'Fearless' Public Subnet Exists"
    ),
    lambda: Test.test(
        Func.sandbox_fearless_public_subnet_configured,
        "Determine if the Sandbox 'Fearless' Public Subnet is Properly Configured"
    ),
    lambda: Test.test(
        Func.sandbox_fearless_public_subnet_rt_configured,
        "Determine if the Sandbox 'Fearless' Public Subnet Route Table is Properly Configured"
    ),
    lambda: Test.test(
        Func.sandbox_speaknow_public_subnet_exists,
        "Determine if the Sandbox 'SpeakNow' Public Subnet Exists"
    ),
    lambda: Test.test(
        Func.sandbox_speaknow_public_subnet_configured,
        "Determine if the Sandbox 'SpeakNow' Public Subnet is Properly Configured"
    ),
    lambda: Test.test(
        Func.sandbox_speaknow_public_subnet_rt_configured,
        "Determine if the Sandbox 'SpeakNow' Public Subnet Route Table is Properly Configured"
    )
]


def root_test_suite() -> bool:
    """
    Execute all the tests related to the root infrastructure of my AWS account
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Root Test Suite")