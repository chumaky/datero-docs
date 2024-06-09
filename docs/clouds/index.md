---
description: Datero cloud installations.
---

# Clouds
Datero is a containerized application.
This means that you can use it in any environment where you can run containers.
This includes cloud environments like AWS, GCP, Azure, etc.

!!! info "Work in progress"
    Documentation for cloud environments is in progress. 
    It will be extended with the time.
    If you don't see a guide for your cloud environment or specific service, it doesn't mean that Datero can't be used there.
    It's just not documented yet.

## Individual guides
- [:simple-amazonwebservices: AWS](./aws/index.md)
- [:material-google-cloud: GCP](./gcp/index.md)
- [:material-microsoft-azure: Azure](./azure/index.md)

## IPv6 support
Datero web application is configured to listen on both IPv4 and IPv6 addresses.
It's applicable for all clouds and on-premises installations.
For an example of how to serve Datero over IPv6, see [IPv6 Support](../administration/ipv6.md).
