---
description: IPv6 support in Datero. 
---

# IPv6 support
Since start of the Internet era, the IPv4 protocol was used as the main protocol for communication between devices.
IPv6 was just a label, that was used in the context of the future.
Apparently, that future has come now and IT world is facing the necessity to support IPv6.

First sign that full support of IPv6 will become a mandatory requirement very soon is an [announcement :octicons-tab-external-16:](https://aws.amazon.com/blogs/aws/new-aws-public-ipv4-address-charge-public-ip-insights/){: target="_blank" rel="noopener noreferrer" } from AWS about introducing charges for public IPv4 addresses starting from February 1, 2024.

!!! quote "AWS announcement"
    We are introducing a new charge for public IPv4 addresses. Effective February 1, 2024 there will be a charge of $0.005 per IP per hour for all public IPv4 addresses, whether attached to a service or not (there is already a charge for public IPv4 addresses you allocate in your account but don’t attach to an EC2 instance).


Datero is ready for this change and supports IPv6 for its web application.
You could host Datero on the dual or IPv6 only network and access it from the IPv6 enabled devices.