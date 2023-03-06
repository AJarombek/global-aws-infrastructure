-- Queries to use within AWS Config
-- Author: Andrew Jarombek
-- Date: 3/5/2023

-- View resources within a VPC

SELECT
  resourceId,
  resourceName,
  resourceType,
  tags,
  availabilityZone
WHERE
  relationships.resourceId = '{VPC ID}'
