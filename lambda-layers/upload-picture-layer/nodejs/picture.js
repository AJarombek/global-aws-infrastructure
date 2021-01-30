/**
 * AWS Lambda layer to upload a picture to an AWS S3 bucket.
 * @author Andrew Jarombek
 * @since 1/29/2021
 */

const AWS = require('aws-sdk');

AWS.config.update({region: 'us-east-1'});

const s3 = new AWS.S3();

exports.upload = async (bucket, base64Image, key) => {
    const body = new Buffer.from(base64Image.replace(/^data:image\/\w+;base64,/, ''), 'base64')
    const type = base64Image.split(';')[0].split('/')[1]

    try {
        const data = await s3.putObject({
            Bucket: bucket,
            Key: key,
            Body: body,
            ACL: 'public-read',
            ContentEncoding: 'base64',
            ContentType: `image/${type}`
        }).promise();

        console.info(data);
        return true;
    } catch (e) {
        console.error(`Failed to upload ${key}`);
        console.error(e);
        return false;
    }
};