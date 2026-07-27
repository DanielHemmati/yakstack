# Yakstack

<p align="center">
  <img src="./assets/yak.png" alt="YakStack - recursive yak shaving for DevOps labs" width="900">
</p>

Yakstack is my hands-on DevOps/DevSecOps/SRE/Platform Engineering/MLOps, <some_name>Ops 😂 learning repository.

It is where I experiment with infrastructure, automation, Kubernetes, CI/CD, GitOps, observability, security, ...
Basically **anything that improves software delivery.**

The goal is not only to learn tools, but to understand how they work together in real-world systems.

## Repository structure

```txt
.
├── assets
├── labs
├── patterns
└── projects
```

`labs/`

Small, focused experiments used to learn or test one concept. Here, our goal is not to be production-ready
but to just make it work and see how it does work.

Example:

- [Kubernetes readiness and liveness probes](https://github.com/DanielHemmati/yakstack/tree/main/labs/01-readiness-liveness-probe)
- [EC2 SSH access](https://github.com/DanielHemmati/yakstack/tree/main/labs/02-ec2-ssh-access)
- [How Terraform and Ansible work together](https://github.com/DanielHemmati/yakstack/tree/main/labs/03-tf-ansible-playground)
- And many more in the `labs/` folder

A lab should be easy to run, understand, and remove.

`patterns/`

Reusable solutions to common infrastructure and DevOps problems. For example, my current Terraform EC2 creation
can be a pattern (not good for production, but good for labs for now)

`projects/`

Complete, end-to-end implementations that solve larger problems. The goal here is to be production-ready.
Here, we will use Tailscale to access resources, AWS SSM to run Ansible playbooks, and AWS Secrets Manager or Vault to store secrets.
If we write Terraform, we will test it with Terratest, OPA, and other production-grade checks.

Every step matters here: every project should be secure, observable, reliable, reproducible, and built with production-grade practices in mind.

`assets/`

Just the header image.
