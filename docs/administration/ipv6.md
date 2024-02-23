---
description: IPv6 support in Datero. 
---

# IPv6 Support
Since start of the Internet era, the IPv4 protocol was used as the main protocol for communication between devices.
IPv6 was just a label, that was used in the context of the future.
Apparently, that future has come now and IT world is facing the necessity to support IPv6.

First sign that full support of IPv6 will become a mandatory requirement very soon is an [announcement :octicons-tab-external-16:](https://aws.amazon.com/blogs/aws/new-aws-public-ipv4-address-charge-public-ip-insights/){: target="_blank" rel="noopener noreferrer" } from AWS about introducing charges for public IPv4 addresses starting from February 1, 2024.

!!! quote "AWS announcement"
    We are introducing a new charge for public IPv4 addresses. Effective February 1, 2024 there will be a charge of $0.005 per IP per hour for all public IPv4 addresses, whether attached to a service or not (there is already a charge for public IPv4 addresses you allocate in your account but don’t attach to an EC2 instance).

Datero is ready for this change and supports IPv6 for its web application.
You could host Datero on the dual or IPv6 only network and access it from the IPv6 enabled devices.


## Datero IPv6 support
Datero is a containerized application that could be hosted on any infrastructure.
It could be local installation on your personal laptop, on-premises installation in your data center or cloud installation in AWS, Azure, GCP or any other cloud provider.

Datero web application is configured to listen on both IPv4 and IPv6 addresses.
Let's see how it's done.


## Serve Datero over IPv6
As an example, let's consider the case when Datero is served via [AWS ECS](../clouds/aws/ecs.md).
AWS advises to use `awsvpc` network mode for ECS tasks, which provides each task with its own elastic network interface (ENI).
This network interface doesn't get public IPv4 address by default.

<figure markdown>
  ![Task definition](../images/clouds/aws/ecs_ipv6_task_awsvpc_mode.jpg){ loading=lazy }
  <figcaption>Task definition</figcaption>
</figure>

But if your VPC is configured to support IPv6, it will get IPv6 address assigned as well.
VPC IPv6 setup is out of scope of this article, but you could find more information in the [official documentation :octicons-tab-external-16:](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-migrate-ipv6.html){: target="_blank" rel="noopener noreferrer" }. 

<figure markdown>
  ![ENI IPv6](../images/clouds/aws/ecs_ipv6_task_eni_ips.jpg){ loading=lazy }
  <figcaption>ENI IPv6</figcaption>
</figure>

So, now we are in position when the ECS task running Datero container has IPv6 but don't have public IPv4 address.
The last missing piece is to make sure that the security group, that is attached to the ECS task ENI, allows incoming traffic on the port 80 from the IPv6 address range.

<figure markdown>
  ![ENI Security Group](../images/clouds/aws/ecs_ipv6_task_security_group.jpg){ loading=lazy }
  <figcaption>ENI Security Group with IPv6 support</figcaption>
</figure>

Now, you could access Datero web application by using the IPv6 address of the ECS task's ENI.
Assuming you mapped the port `80` of the Datero container to the port `80` of the ECS task,
just copy the IPv6 address from the ENI and paste it into the browser address bar in the square brackets `http://[ipv6_address]`.
If you mapped to the different port, just append it to the address `http://[ipv6_address]:port`.

<figure markdown>
  ![Datero UI over IPv6](../images/clouds/aws/ecs_ipv6_datero_ui.jpg){ loading=lazy }
  <figcaption>Datero UI over IPv6</figcaption>
</figure>

That's it. You have successfully accessed Datero web application over IPv6!
Pretty simple, isn't it?

!!! note "Security consideration"
    Purpose of this article is to show how to serve Datero over IPv6.
    It doesn't cover the security aspects of the IPv6 setup.

    AWS advises to serve ECS tasks over private IPv4 addresses by default.
    And if you need internet access, you should use NAT gateway or NAT instance.
    Or put your tasks behind an application load balancer with public IP address.

    It might be completely unacceptable from security perspective to exposure any web application to the internet over IPv6,
    while not having it available over IPv4.