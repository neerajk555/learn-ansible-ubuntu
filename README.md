# Learn Ansible from Scratch on Ubuntu 🐧⚙️

> A comprehensive, beginner-friendly course designed for Ubuntu users with no prior automation experience

## 🎯 Course Overview

This course teaches Ansible automation from absolute basics to deploying complete application stacks. Perfect for beginners using Ubuntu Linux who want hands-on, practical experience with infrastructure automation.

### Target Audience
- **Absolute beginners** (no prior DevOps/automation experience)
- **Ubuntu Linux users** (all examples tested on Ubuntu)
- **Hands-on learners** who prefer practical exercises over theory

### What You'll Learn
- Install and configure Ansible on Ubuntu
- Write YAML playbooks to automate server tasks  
- Manage multiple servers with inventories and SSH
- Use variables, templates, and roles for scalable automation
- Deploy web applications and database systems
- Follow DevOps best practices with Git version control
- Build a complete LAMP stack automatically

## 📚 Course Structure

Each lesson follows a consistent format:
- **Learning Objectives** - Clear goals for the lesson
- **Concept Overview** - Plain-English explanations with analogies
- **Step-by-Step Tutorial** - Ubuntu-specific commands you can copy-paste
- **Code Examples** - Complete YAML playbooks and configuration files  
- **Hands-On Exercise** - Practice tasks to reinforce learning
- **Troubleshooting Tips** - Common errors and solutions
- **Summary** - Key takeaways and next steps

## 🗓️ Lesson Plan

### Foundations (Lessons 1-5)
| Lesson | Topic | Duration |
|--------|--------|----------|
| [1](lessons/lesson-01-introduction.md) | Introduction to Ansible and Configuration Management | 30 min |
| [2](lessons/lesson-02-installation.md) | Installing and Verifying Ansible on Ubuntu | 45 min |
| [3](lessons/lesson-03-inventory.md) | Understanding Ansible Inventory and Host Management | 45 min |
| [4](lessons/lesson-04-first-playbook.md) | Writing Your First Playbook | 60 min |
| [5](lessons/lesson-05-packages-services.md) | Managing Packages and Services with Ansible | 60 min |

### Core Concepts (Lessons 6-10)  
| Lesson | Topic | Duration |
|--------|--------|----------|
| [6](lessons/lesson-06-variables-facts.md) | Using Variables and Facts | 75 min |
| [7](lessons/lesson-07-conditionals-loops.md) | Conditionals, Loops, and Handlers | 75 min |
| [8](lessons/lesson-08-templates.md) | Working with Templates (Jinja2) | 90 min |
| [9](lessons/lesson-09-files-users.md) | File and User Management | 75 min |
| [10](lessons/lesson-10-multi-node.md) | Setting Up Multi-Node Environments | 90 min |

### Advanced Topics (Lessons 11-15)
| Lesson | Topic | Duration |
|--------|--------|----------|
| [11](lessons/lesson-11-roles.md) | Creating and Using Roles | 90 min |
| [12](lessons/lesson-12-debugging.md) | Error Handling and Debugging in Ansible | 75 min |
| [13](lessons/lesson-13-web-app.md) | Deploying a Simple Web Application | 90 min |
| [14](lessons/lesson-14-best-practices.md) | Best Practices, Directory Structure, and Version Control | 60 min |
| [15](lessons/lesson-15-lamp-project.md) | **Final Project**: Automate a Full LAMP Stack Deployment | 120 min |

**Total Course Time:** ~15 hours of hands-on learning

## 🚀 Quick Start

1. **Prerequisites**: Ubuntu 20.04+ with internet access
2. **Start here**: [Lesson 1: Introduction to Ansible](lessons/lesson-01-introduction.md)
3. **Follow sequentially**: Each lesson builds on previous concepts
4. **Practice**: Complete all hands-on exercises for best results

## 🧭 Why localhost? Local vs web server

We start on localhost (your own Ubuntu machine/VM) because it’s fast, safe, and requires no SSH setup. Ansible can run tasks directly on the control node when you set `ansible_connection=local`, so there’s no network dependency. The same playbooks later work on real servers—just switch your inventory to remote hosts and use SSH.

- Localhost: runs tasks locally with `ansible_connection=local` (no SSH)
- Remote web server: runs tasks over SSH to another machine
- Privileges: `become: yes` still uses sudo locally or remotely
- Inventory: `localhost` entry vs. IP/hostnames for real servers

Read the detailed guide with examples and pitfalls: [docs/localhost-vs-webserver.md](docs/localhost-vs-webserver.md)

## 💻 What You'll Build

By the end of this course, you'll have:

- ✅ **Automated server setup** - Install packages, configure services, manage users
- ✅ **Multi-node infrastructure** - Control multiple VMs with a single command  
- ✅ **Web application deployment** - Deploy static sites with dynamic templates
- ✅ **Complete LAMP stack** - Automated Linux + Apache + MySQL + PHP deployment
- ✅ **Production-ready practices** - Version control, error handling, debugging
- ✅ **Reusable automation** - Organized roles and playbooks for future projects

### Final Project Preview
Your capstone project automatically provisions:
```bash
# Single command deploys everything:
ansible-playbook playbooks/lamp.yml
```
- 🌐 Apache web servers with PHP
- 🗄️ MariaDB database with sample data  
- 🔗 PHP application connecting to database
- 🛡️ Secure configuration and user management
- 📊 Real working web application with database integration

## 🛠️ Course Materials

### Directory Structure
```
ansible-01/
├── lessons/           # Individual lesson files
├── exercises/         # Practice exercises and solutions
├── examples/          # Complete code examples
└── README.md         # This file
```

## 🎯 Bonus Exercises

Ready for additional challenges? Try these practical exercises:

| Exercise | Topic | Difficulty | Duration |
|----------|-------|------------|----------|
| [Node.js Installation](exercises/nodejs-installation.md) | Automated Node.js and npm setup with sample app | Beginner | 45 min |
| [Node.js on Remote Server](exercises/nodejs-remote-installation.md) | SSH-based install with inventory, Python bootstrap, and sample app | Intermediate | 60 min |
| [Apache over SSH (localhost)](exercises/apache-ssh-local.md) | Establish SSH connectivity to 127.0.0.1 and install Apache | Beginner | 30 min |
| [Creating Ansible Roles (MOTD)](exercises/ansible-roles-motd.md) | Build reusable roles with tasks, templates, variables, and handlers | Intermediate | 90 min |

More exercises coming soon! Each exercise includes:
- Complete playbook examples
- Step-by-step instructions
- Troubleshooting guides
- Challenge variations for extra practice

### Example Files Provided
- Complete Ansible playbooks for each lesson
- Template files (Nginx configs, HTML, PHP apps)  
- Inventory examples for different environments
- Best practice configurations and project structures

## 🔧 System Requirements

- **Operating System**: Ubuntu 20.04 LTS or newer
- **Memory**: 4GB RAM minimum (8GB recommended for VMs)
- **Storage**: 10GB free space
- **Network**: Internet connection for package installation
- **Optional**: Multipass for creating test VMs (covered in Lesson 10)

## 🤝 Course Philosophy  

This course emphasizes:
- **Learning by doing** - Every concept includes hands-on practice
- **Plain English** - Complex topics explained simply with real-world analogies  
- **Copy-paste ready** - All commands work on Ubuntu without modification
- **Progressive complexity** - Start simple, build advanced skills gradually
- **Real-world focus** - Learn patterns you'll actually use in production

## 📖 Additional Resources

- **Ansible Documentation**: [docs.ansible.com](https://docs.ansible.com)
- **Ubuntu Server Guide**: [ubuntu.com/server/docs](https://ubuntu.com/server/docs)  
- **YAML Syntax**: [yaml.org](https://yaml.org)
- **Jinja2 Templates**: [jinja.palletsprojects.com](https://jinja.palletsprojects.com)

## ❓ Getting Help

If you encounter issues:
1. Check the **Troubleshooting Tips** in each lesson
2. Review command syntax and YAML indentation  
3. Use `ansible-playbook --check --diff` for dry runs
4. Enable verbose output with `-vvv` flag

## 🏆 Completion Certificate

After finishing Lesson 15, you'll have:
- Deployed a complete LAMP stack using Ansible
- Mastered essential automation concepts
- Built reusable infrastructure code
- Gained practical DevOps skills for real environments

**Ready to automate everything?** Start with [Lesson 1: Introduction to Ansible →](lessons/lesson-01-introduction.md)

---

*Happy learning and automating! 🚀*