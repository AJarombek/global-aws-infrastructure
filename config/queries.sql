-- Queries to use within AWS Config
-- Author: Andrew Jarombek
-- Date: 3/5/2023

-- View all resources

SELECT
  *

-- View newly created resources

SELECT
  *
ORDER BY
  resourceCreationTime DESC

-- Get number of RDS instances grouped by database engines

SELECT
  configuration.engine,
  COUNT(*)
WHERE
  resourceType = 'AWS::RDS::DBInstance'
GROUP BY
  configuration.engine

-- List all EC2 instances

SELECT
  resourceId,
  configuration.instanceType,
  availabilityZone,
  configuration.state.name
WHERE
  resourceType = 'AWS::EC2::Instance'

-- View resources within a VPC

SELECT
  resourceId,
  resourceName,
  resourceType,
  tags,
  availabilityZone
WHERE
  relationships.resourceId = '{VPC ID}'
