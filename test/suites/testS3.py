"""
Functions which represent Unit tests for the global.jarombek.io S3 bucket infrastructure
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest

import boto3
from boto3_type_annotations.sts import Client as STSClient
from boto3_type_annotations.s3 import Client as S3Client
from boto3_type_annotations.s3control import Client as S3ControlClient
from boto3_type_annotations.cloudfront import Client as CloudfrontClient


class TestS3(unittest.TestCase):
    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.sts: STSClient = boto3.client("sts")
        self.s3: S3Client = boto3.client("s3")
        self.s3_control: S3ControlClient = boto3.client("s3control")
        self.cloudfront: CloudfrontClient = boto3.client("cloudfront")

    def test_s3_account_public_access_block(self) -> None:
        """
        Test if the AWS account has the proper S3 public access settings
        """
        account_id = self.sts.get_caller_identity().get("Account")
        public_access_block = self.s3_control.get_public_access_block(
            AccountId=account_id
        )

        config = public_access_block.get("PublicAccessBlockConfiguration")
        self.assertTrue(config.get("BlockPublicAcls"))
        self.assertTrue(config.get("IgnorePublicAcls"))
        self.assertTrue(config.get("BlockPublicPolicy"))
        self.assertTrue(config.get("RestrictPublicBuckets"))

    def test_s3_bucket_exists(self) -> None:
        """
        Test if an S3 bucket for global.jarombek.io exists
        """
        s3_bucket = self.s3.list_objects(Bucket="global.jarombek.io")
        return s3_bucket.get("Name") == "global.jarombek.io"

    def test_s3_bucket_public_access(self) -> None:
        """
        Test whether the public access configuration for a global.jarombek.io S3 bucket is correct
        """
        public_access_block = self.s3.get_public_access_block(
            Bucket="global.jarombek.io"
        )
        config = public_access_block.get("PublicAccessBlockConfiguration")
        self.assertTrue(config.get("BlockPublicAcls"))
        self.assertTrue(config.get("IgnorePublicAcls"))
        self.assertTrue(config.get("BlockPublicPolicy"))
        self.assertTrue(config.get("RestrictPublicBuckets"))

    def test_s3_bucket_objects_correct(self) -> None:
        """
        Test if the S3 bucket for global.jarombek.io contains the proper objects
        """
        contents = self.s3.list_objects(Bucket="global.jarombek.io").get("Contents")
        self.assertTrue(
            all(
                [
                    len(contents) == 25,
                    contents[0].get("Key") == "aws-key-gen.sh",
                    contents[1].get("Key") == "fonts.css",
                    contents[2].get("Key") == "fonts/Allura-Regular.otf",
                    contents[3].get("Key") == "fonts/ElegantIcons.eot",
                    contents[4].get("Key") == "fonts/ElegantIcons.ttf",
                    contents[5].get("Key") == "fonts/ElegantIcons.woff",
                    contents[6].get("Key") == "fonts/FantasqueSansMono-Bold.eot",
                    contents[7].get("Key") == "fonts/FantasqueSansMono-Bold.otf",
                    contents[8].get("Key") == "fonts/FantasqueSansMono-Bold.ttf",
                    contents[9].get("Key") == "fonts/FantasqueSansMono-Bold.woff",
                    contents[10].get("Key") == "fonts/FantasqueSansMono-Bold.woff2",
                    contents[11].get("Key") == "fonts/Longway-Regular.otf",
                    contents[12].get("Key") == "fonts/Roboto-Bold.ttf",
                    contents[13].get("Key") == "fonts/Roboto-Regular.ttf",
                    contents[14].get("Key") == "fonts/Roboto-Thin.ttf",
                    contents[15].get("Key") == "fonts/RobotoSlab-Bold.ttf",
                    contents[16].get("Key") == "fonts/RobotoSlab-Light.ttf",
                    contents[17].get("Key") == "fonts/RobotoSlab-Regular.ttf",
                    contents[18].get("Key") == "fonts/RobotoSlab-Thin.ttf",
                    contents[19].get("Key") == "fonts/SylexiadSansThin-Bold.otf",
                    contents[20].get("Key") == "fonts/SylexiadSansThin-Bold.ttf",
                    contents[21].get("Key") == "fonts/SylexiadSansThin.otf",
                    contents[22].get("Key") == "fonts/SylexiadSansThin.ttf",
                    contents[23].get("Key") == "fonts/dyslexie-bold.ttf",
                    contents[24].get("Key") == "index.json",
                ]
            )
        )

    def test_s3_bucket_cloudfront_distributed(self) -> None:
        """
        Ensure that the S3 bucket is distributed with CloudFront as expected
        """
        distributions = self.cloudfront.list_distributions()
        dist_list = distributions.get("DistributionList").get("Items")
        dist = [
            item
            for item in dist_list
            if item.get("Aliases").get("Items")[0] == "global.jarombek.io"
        ][0]

        self.assertTrue(
            all(
                [
                    dist.get("Status") == "Deployed",
                    dist.get("DefaultCacheBehavior")
                    .get("AllowedMethods")
                    .get("Quantity")
                    == 3,
                    dist.get("DefaultCacheBehavior")
                    .get("AllowedMethods")
                    .get("Items")[0]
                    == "HEAD",
                    dist.get("DefaultCacheBehavior")
                    .get("AllowedMethods")
                    .get("Items")[1]
                    == "GET",
                    dist.get("DefaultCacheBehavior")
                    .get("AllowedMethods")
                    .get("Items")[2]
                    == "OPTIONS",
                    dist.get("DefaultCacheBehavior")
                    .get("AllowedMethods")
                    .get("CachedMethods")
                    .get("Quantity")
                    == 3,
                    dist.get("DefaultCacheBehavior")
                    .get("AllowedMethods")
                    .get("CachedMethods")
                    .get("Items")[0]
                    == "HEAD",
                    dist.get("DefaultCacheBehavior")
                    .get("AllowedMethods")
                    .get("CachedMethods")
                    .get("Items")[1]
                    == "GET",
                    dist.get("DefaultCacheBehavior")
                    .get("AllowedMethods")
                    .get("CachedMethods")
                    .get("Items")[2]
                    == "OPTIONS",
                    dist.get("Restrictions")
                    .get("GeoRestriction")
                    .get("RestrictionType")
                    == "none",
                    dist.get("HttpVersion") == "HTTP2",
                ]
            )
        )
