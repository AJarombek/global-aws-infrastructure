### Overview

Top level directory for the `global.jarombek.io` and `www.global.jarombek.io` S3 buckets.  The default page is 
`index.json` and the other files are retrieved using absolute paths in the bucket URL.  For example, `fonts.css` is 
retrieved with the following two URLS:


> global.jarombek.com/fonts.css
> www.global.jarombek.com/fonts.css

### Files

| Filename            | Description                                                                             |
|---------------------|-----------------------------------------------------------------------------------------|
| `fonts/`            | Fonts commonly used in my applications                                                  |
| `index.json`        | Index page for the S3 bucket                                                            |
| `fonts.css`         | A CSS file commonly used in my applications.  It imports commonly used fonts            |
| `aws-key-gen.sh`    | Bash file for creating a key to connect to an EC2 instance on AWS                       |