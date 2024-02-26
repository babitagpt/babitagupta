Challenge #1
A 3-tier environment is a common setup. Use a tool of your choosing/familiarity create these
resources on a cloud environment (Azure/AWS/GCP). Please remember we will not be judged
on the outcome but more focusing on the approach, style and reproducibility.

Solution :

This tempplate will deploy :
1. one Resource Group
2. One Virtual Network with three subnets for web, application, and database tiers
3. Network Security Group, one for each subnet
4. Public IP for Load Balancer
5. External Load Balancer to load balance Web Traffic(HTTP & HTTPS) to web servers
6. Virtual Machine Availability sets for Web Tier, Application Tier and Database tier
7. Network Interfaces for Web Tier
