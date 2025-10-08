# MOTD Role

This Ansible role manages the Message of the Day (MOTD) displayed when users log into the system.

## Features
- Dynamic MOTD with system information
- Customizable variables for environment details
- Automatic backup of original MOTD
- Proper file permissions and ownership

## Variables
- `system_manager`: Contact email (default: admin@company.com)
- `environment`: Environment name (default: development)  
- `maintenance_window`: Maintenance schedule info
- `motd_notice`: Custom notice message

## Example Playbook
```yaml
- hosts: servers
  roles:
    - role: motd
      system_manager: "ops@mycompany.com"
      environment: "production"
```

## Role Structure
```
motd/
├── tasks/main.yml      # Main automation tasks
├── templates/motd.j2   # MOTD template with variables
├── defaults/main.yml   # Default variable values
├── handlers/main.yml   # Event-driven tasks
├── meta/main.yml       # Role metadata
└── README.md           # This documentation
```