"""
Functions which represent Unit tests for AWS Lambda layers.
Author: Andrew Jarombek
Date: 1/30/2021
"""

import unittest
from typing import List

import boto3
from boto3_type_annotations.lambda_ import Client as LambdaClient


class TestLambdaLayers(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.lambda_: LambdaClient = boto3.client('lambda')

    def test_upload_picture_layer_exists(self) -> None:
        """
        Test that the 'upload-picture-layer' AWS Lambda layer exists as expected.
        """
        layers_response: dict = self.lambda_.list_layers(CompatibleRuntime='nodejs')
        layers: List[dict] = layers_response.get('Layers')
        matching_layers = [layer for layer in layers if layer.get('LayerName') == 'upload-picture-layer']

        self.assertEqual(1, len(matching_layers))

        runtimes: List[str] = matching_layers[0].get('LatestMatchingVersion').get('CompatibleRuntimes')
        self.assertEqual(3, len(runtimes))
        self.assertIn('nodejs', runtimes)
        self.assertIn('nodejs10.x', runtimes)
        self.assertIn('nodejs12.x', runtimes)
