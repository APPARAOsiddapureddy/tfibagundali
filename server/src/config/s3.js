const { S3Client, GetObjectCommand, PutObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const env = require('./env');

const s3Client = new S3Client({
  region: env.AWS_REGION,
  credentials: env.AWS_ACCESS_KEY_ID
    ? { accessKeyId: env.AWS_ACCESS_KEY_ID, secretAccessKey: env.AWS_SECRET_ACCESS_KEY }
    : undefined,
});

function getPublicUrl(s3Key) {
  if (!s3Key) return null;
  return `${env.CLOUDFRONT_URL}/${s3Key}`;
}

async function getPresignedDownloadUrl(s3Key, expiresIn = 900) {
  const command = new GetObjectCommand({ Bucket: env.S3_BUCKET, Key: s3Key });
  return getSignedUrl(s3Client, command, { expiresIn });
}

async function uploadBuffer(buffer, s3Key, contentType = 'image/jpeg') {
  const command = new PutObjectCommand({
    Bucket: env.S3_BUCKET,
    Key: s3Key,
    Body: buffer,
    ContentType: contentType,
  });
  await s3Client.send(command);
  return s3Key;
}

module.exports = { s3Client, getPublicUrl, getPresignedDownloadUrl, uploadBuffer };
