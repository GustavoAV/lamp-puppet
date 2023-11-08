# LAMP Puppet

Puppet project to setup a standard LAMP (Linux, Apache, MySQL, PHP) stack with Puppet.

> This project is for studying and is **not** intended for production usage.

## Development

We use the tools below for this project development. Install and configure them following the documentations steps.

- [Puppet Bolt](https://www.puppet.com/docs/bolt/latest/bolt_installing.html)
- [Molecule](https://ansible.readthedocs.io/projects/molecule/)
- [Virtual Box](https://www.virtualbox.org/wiki/Documentation)
- [Vagrant](https://developer.hashicorp.com/vagrant/docs)

And then, run:

```bash
molecule converge
```

This creates and configure a LAMP webserver. You can acess the link below to confirm everything is running properly:

- LAMP in Ubuntu 22.04: <http://localhost:8120>

To destroy and remove the VM, simply run:

```bash
molecule destroy
```

## References

- [Puppet docs - Setup](https://www.puppet.com/docs/puppet/8/install_agents)
- [Linode tutorial - Puppet setup](https://www.linode.com/docs/guides/getting-started-with-puppet-6-1-basic-installation-and-setup/)
