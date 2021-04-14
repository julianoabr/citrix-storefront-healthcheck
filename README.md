# Citrix Store Front Health Check #

Citrix StoreFront is an enterprise application store that provides an interface for users to access [XenDesktop](https://searchvirtualdesktop.techtarget.com/definition/Citrix-XenDesktop) and [XenApp](https://searchvirtualdesktop.techtarget.com/definition/Citrix-XenApp) virtual desktops and applications remotely.

StoreFront enables IT administrators to provide users with universal, self-service central access to their [virtual desktops](https://searchvirtualdesktop.techtarget.com/definition/virtual-desktop), applications and any associated data. StoreFront interacts with the [Citrix Receiver](https://searchvirtualdesktop.techtarget.com/definition/Citrix-Receiver) client software to support access to XenDesktop and XenApp servers from Windows, Mac, Apple iOS, Google Android, Linux and HTML5 endpoints.

Citrix's enterprise app store includes [single sign-on](https://searchsecurity.techtarget.com/definition/single-sign-on?_gl=1*1k1v56b*_ga*MTM1NzA2MjYzMC4xNjE3MTAxNzk1*_ga_RRBYR9CGB9*MTYxODA2OTAwNi40LjAuMTYxODA2OTAwNi4w&_ga=2.177127149.979690428.1618069008-1357062630.1617101795) access to apps and desktops using the company's NetScaler Gateway access control management technology. StoreFront also contains security features such as [extensible authentication](https://searchsecurity.techtarget.com/definition/Extensible-Authentication-Protocol-EAP?_gl=1*22i4u0*_ga*MTM1NzA2MjYzMC4xNjE3MTAxNzk1*_ga_RRBYR9CGB9*MTYxODQwMzE3OC41LjAuMTYxODQwMzE4MS4w&_ga=2.220706128.979690428.1618069008-1357062630.1617101795) and smart card authentication.

StoreFront includes a [software developer's kit](https://whatis.techtarget.com/definition/software-developers-kit-SDK?_gl=1*17rrpg2*_ga*MTM1NzA2MjYzMC4xNjE3MTAxNzk1*_ga_RRBYR9CGB9*MTYxODQwMzE3OC41LjAuMTYxODQwMzE4MS4w&_ga=2.183081454.979690428.1618069008-1357062630.1617101795) that allows administrators to further customize the user display and app deployment, such as loading business-critical applications upon login. Administrators can use the Citrix Studio console to centrally manage StoreFront servers.


Citrix released StoreFront in XenDesktop and XenApp 7 as a replacement to the Web Interface feature, but StoreFront is compatible with versions as far back as XenDesktop and XenApp 5.5. StoreFront is also included in Citrix's [Workspace Suite](https://searchvirtualdesktop.techtarget.com/definition/Citrix-Workspace-Suite) and [Workspace Cloud](https://searchvirtualdesktop.techtarget.com/definition/Citrix-Workspace-Cloud) products.


# About this Script #

## This script checks the following parameters on servers: ##

1. General Check
  1. Site
  2. HostBaseURL
  3. URL Reachable
  4. Last Source Server
  5. Last Sync Status
  6. Last Error Message
2. Servers Check
  1. Average CPU Usage
  2. Memory Usage
  3. Disk Space Free
  4. Amount of Citrix Events registered on last 24 houras
3. Services Check on Servers
  1. Citrix Peer Resolution Service
  2. Citrix Cluster Join Service
  3. Citrix Configuration Replication
  4. Citrix Credential Wallet
  5. Citrix Default Domain Service
  6. Citrix Store Front Priviled Admin Service
  7. Citrix Service Monitor
  8. Citrix Subscription Store
  9. Citrix Telemetry Service
  10. WWW Publishing Service











