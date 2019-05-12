"""
Functions which represent Unit tests for the global.jarombek.io S3 bucket infrastructure
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3

s3 = boto3.client('s3')
cloudfront = boto3.client('cloudfront')


def s3_bucket_exists() -> bool:
    """
    Test if an S3 bucket for global.jarombek.io exists
    :return: True if the bucket exists, False otherwise
    """
    s3_bucket = s3.list_objects(Bucket='global.jarombek.io')
    return s3_bucket.get('Name') == 'global.jarombek.io'


def s3_bucket_objects_correct() -> bool:
    """
    Test if the S3 bucket for global.jarombek.io contains the proper objects
    :return: True if the objects are as expected, False otherwise
    """
    contents = s3.list_objects(Bucket='global.jarombek.io').get('Contents')
    return all([
        len(contents) == 8,
        contents[0].get('Key') == 'aws-key-gen.sh',
        contents[1].get('Key') == 'fonts.css',
        contents[2].get('Key') == 'fonts/FantasqueSansMono-Bold.ttf',
        contents[3].get('Key') == 'fonts/Longway-Regular.otf',
        contents[4].get('Key') == 'fonts/SylexiadSansThin-Bold.ttf',
        contents[5].get('Key') == 'fonts/SylexiadSansThin.ttf',
        contents[6].get('Key') == 'fonts/dyslexie-bold.ttf',
        contents[7].get('Key') == 'index.json'
    ])


def s3_bucket_cloudfront_distributed() -> bool:
    """
    Ensure that the S3 bucket is distributed with CloudFront as expected
    :return: True if its distributed, False otherwise
    """
    distributions = cloudfront.list_distributions()
    dist_list = distributions.get('DistributionList').get('Items')
    dist = [item for item in dist_list if item.get('Aliases').get('Items')[0] == 'global.jarombek.io'][0]

    return all([
        dist.get('Status') == 'Deployed',
        dist.get('DefaultCacheBehavior').get('AllowedMethods').get('Quantity') == 2,
        dist.get('DefaultCacheBehavior').get('AllowedMethods').get('Items')[0] == 'HEAD',
        dist.get('DefaultCacheBehavior').get('AllowedMethods').get('Items')[1] == 'GET',
        dist.get('Restrictions').get('GeoRestriction').get('RestrictionType') == 'whitelist',
        dist.get('Restrictions').get('GeoRestriction').get('Items')[0] == 'US'
    ])
