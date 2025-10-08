# Lesson 15: Final Project — Automate a Full LAMP Stack Deployment

## Learning Objectives
- Provision Apache, MariaDB/MySQL, and PHP on Ubuntu.
- Secure the database and create a DB and user.
- Deploy a simple PHP app that connects to the database.

## Concept Overview
LAMP = Linux + Apache + MySQL/MariaDB + PHP. You'll automate installing packages, configuring services, creating a database, and deploying a basic app.

We'll use MariaDB (the `mysql_*` modules work with PyMySQL driver).

## Step-by-Step Tutorial (Ubuntu)
1. **Create variables for the DB:**
   ```bash
   nano group_vars/db.yml
   ```
   Paste:
   ```yaml
   # Database configuration
   db_root_password: "ChangeMe_Root_2023!"
   app_db_name: "myapp"
   app_db_user: "myappuser"
   app_db_password: "ChangeMe_App_2023!"
   mysql_packages:
     - mariadb-server
     - python3-pymysql
   ```

2. **Create web server variables:**
   ```bash
   nano group_vars/web.yml
   ```
   Paste:
   ```yaml
   # Web server configuration
   php_packages:
     - php
     - libapache2-mod-php
     - php-mysql
     - php-curl
   apache_packages:
     - apache2
   web_root: /var/www/html
   ```

3. **Create the LAMP playbook:**
   ```bash
   nano playbooks/lamp.yml
   ```
   Paste:
   ```yaml
   ---
   - name: LAMP Stack - Web Servers
     hosts: web
     become: true
     tasks:
       - name: Install Apache and PHP packages
         ansible.builtin.apt:
           name: "{{ apache_packages + php_packages }}"
           state: present
           update_cache: yes

       - name: Ensure Apache is running and enabled
         ansible.builtin.service:
           name: apache2
           state: started
           enabled: yes

       - name: Deploy PHP info page
         ansible.builtin.copy:
           dest: "{{ web_root }}/info.php"
           content: |
             <?php
             echo "<h1>PHP Info for " . gethostname() . "</h1>";
             phpinfo();
           owner: www-data
           group: www-data
           mode: '0644'

       - name: Enable PHP module for Apache
         ansible.builtin.apache2_module:
           name: php8.1
           state: present
         notify: Restart Apache

     handlers:
       - name: Restart Apache
         ansible.builtin.service:
           name: apache2
           state: restarted

   - name: LAMP Stack - Database Servers
     hosts: db
     become: true
     tasks:
       - name: Install MariaDB and Python MySQL libraries
         ansible.builtin.apt:
           name: "{{ mysql_packages }}"
           state: present
           update_cache: yes

       - name: Ensure MariaDB is running and enabled
         ansible.builtin.service:
           name: mariadb
           state: started
           enabled: yes

       - name: Set MariaDB root password
         ansible.builtin.mysql_user:
           name: root
           password: "{{ db_root_password }}"
           login_unix_socket: /var/run/mysqld/mysqld.sock
           state: present
         ignore_errors: yes

       - name: Create .my.cnf file for root
         ansible.builtin.copy:
           dest: /root/.my.cnf
           content: |
             [client]
             user=root
             password={{ db_root_password }}
           owner: root
           group: root
           mode: '0600'

       - name: Remove anonymous users
         ansible.builtin.mysql_user:
           name: ''
           host_all: yes
           state: absent

       - name: Create application database
         ansible.builtin.mysql_db:
           name: "{{ app_db_name }}"
           state: present

       - name: Create application database user
         ansible.builtin.mysql_user:
           name: "{{ app_db_user }}"
           password: "{{ app_db_password }}"
           priv: "{{ app_db_name }}.*:ALL"
           host: "%"
           state: present

       - name: Create sample table and data
         ansible.builtin.mysql_query:
           query: |
             CREATE TABLE IF NOT EXISTS {{ app_db_name }}.users (
               id INT AUTO_INCREMENT PRIMARY KEY,
               name VARCHAR(100) NOT NULL,
               email VARCHAR(100) NOT NULL,
               created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
             );
             INSERT IGNORE INTO {{ app_db_name }}.users (id, name, email) VALUES
             (1, 'Alice Johnson', 'alice@example.com'),
             (2, 'Bob Smith', 'bob@example.com'),
             (3, 'Charlie Brown', 'charlie@example.com');
   ```

4. **Create PHP application template:**
   ```bash
   nano templates/app.php.j2
   ```
   Paste:
   ```php
   <?php
   $host = '{{ groups["db"][0] }}';
   $dbname = '{{ app_db_name }}';
   $username = '{{ app_db_user }}';
   $password = '{{ app_db_password }}';

   try {
       $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
       $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
       
       echo "<html><head><title>LAMP Stack Demo</title>";
       echo "<style>body{font-family:sans-serif;margin:2rem;} .success{color:green;} .error{color:red;} table{border-collapse:collapse;width:100%;} th,td{border:1px solid #ddd;padding:8px;text-align:left;} th{background:#f2f2f2;}</style></head><body>";
       echo "<h1>🚀 LAMP Stack Successfully Deployed!</h1>";
       echo "<p class='success'>✅ Database Connection: SUCCESS</p>";
       echo "<p><strong>Connected to:</strong> $host</p>";
       echo "<p><strong>Database:</strong> $dbname</p>";
       
       $stmt = $pdo->query('SELECT * FROM users ORDER BY id');
       echo "<h2>Sample Users Table:</h2>";
       echo "<table>";
       echo "<tr><th>ID</th><th>Name</th><th>Email</th><th>Created</th></tr>";
       
       while ($row = $stmt->fetch()) {
           echo "<tr>";
           echo "<td>" . htmlspecialchars($row['id']) . "</td>";
           echo "<td>" . htmlspecialchars($row['name']) . "</td>";
           echo "<td>" . htmlspecialchars($row['email']) . "</td>";
           echo "<td>" . htmlspecialchars($row['created_at']) . "</td>";
           echo "</tr>";
       }
       echo "</table>";
       
       echo "<hr><p><a href='info.php'>View PHP Info</a> | <a href='/'>Home</a></p>";
       echo "</body></html>";
       
   } catch (PDOException $e) {
       echo "<html><body style='font-family:sans-serif;margin:2rem;'>";
       echo "<h1>❌ Database Connection Failed</h1>";
       echo "<p class='error'>Error: " . htmlspecialchars($e->getMessage()) . "</p>";
       echo "<p>Check your database configuration and try again.</p>";
       echo "</body></html>";
   }
   ?>
   ```

5. **Create application deployment playbook:**
   ```bash
   nano playbooks/deploy_app.yml
   ```
   Paste:
   ```yaml
   ---
   - name: Deploy PHP Application
     hosts: web
     become: true
     tasks:
       - name: Deploy main application
         ansible.builtin.template:
           src: templates/app.php.j2
           dest: "{{ web_root }}/app.php"
           owner: www-data
           group: www-data
           mode: '0644'

       - name: Create homepage
         ansible.builtin.copy:
           dest: "{{ web_root }}/index.html"
           content: |
             <!DOCTYPE html>
             <html>
             <head>
                 <title>LAMP Stack Demo</title>
                 <style>
                     body { font-family: sans-serif; margin: 2rem; background: #f5f5f5; }
                     .container { max-width: 600px; margin: 0 auto; background: white; padding: 2rem; border-radius: 8px; }
                     .btn { display: inline-block; padding: 10px 20px; background: #007cba; color: white; text-decoration: none; border-radius: 4px; margin: 5px; }
                 </style>
             </head>
             <body>
                 <div class="container">
                     <h1>🐧 LAMP Stack on Ubuntu</h1>
                     <p>Welcome to your Ansible-deployed LAMP stack!</p>
                     <p>This demonstrates:</p>
                     <ul>
                         <li>✅ Linux (Ubuntu)</li>
                         <li>✅ Apache Web Server</li>
                         <li>✅ MariaDB Database</li>
                         <li>✅ PHP Application</li>
                     </ul>
                     <a href="app.php" class="btn">View Database App</a>
                     <a href="info.php" class="btn">PHP Info</a>
                 </div>
             </body>
             </html>
           owner: www-data
           group: www-data
           mode: '0644'
   ```

6. **Install required Ansible collection:**
   ```bash
   ansible-galaxy collection install community.mysql
   ```

7. **Run the complete deployment:**
   ```bash
   # Deploy LAMP stack
   ansible-playbook playbooks/lamp.yml

   # Deploy application
   ansible-playbook playbooks/deploy_app.yml
   ```

8. **Test the deployment:**
   ```bash
   # Test homepage
   curl http://<WEB1_IP>/

   # Test PHP application
   curl http://<WEB1_IP>/app.php

   # Test PHP info
   curl http://<WEB1_IP>/info.php
   ```

## Code Examples
- Complete LAMP stack configuration with secure database setup and PHP application.

## Hands-On Exercise
- Add SSL/HTTPS support using Let's Encrypt or self-signed certificates.
- Create an additional table for blog posts and display them in the PHP app.
- Add a role-based structure for the LAMP components.

## Troubleshooting Tips
- "Module community.mysql.mysql_db not found": ensure you ran `ansible-galaxy collection install community.mysql`
- "Access denied for user 'root'": check the `.my.cnf` file was created correctly
- "Connection refused": ensure MariaDB is listening on the correct interface (edit `/etc/mysql/mariadb.conf.d/50-server.cnf` to set `bind-address = 0.0.0.0`)
- PHP not working: check Apache error logs with `tail -f /var/log/apache2/error.log`

## Summary / Key Takeaways
- 🎉 **Congratulations!** You've automated a complete LAMP stack deployment
- Demonstrated multi-tier application deployment with Ansible
- Integrated database provisioning, web server configuration, and application deployment
- Used templates to create dynamic, host-specific content

## Course Completion
You now have the skills to:
- ✅ Install and configure Ansible on Ubuntu
- ✅ Manage inventories and SSH connectivity  
- ✅ Write playbooks using variables, facts, conditionals, loops, and handlers
- ✅ Use templates and roles for scalable organization
- ✅ Handle errors and debug effectively
- ✅ Deploy complete application stacks across multiple nodes

**Keep practicing** by refactoring your LAMP solution into roles, adding monitoring, implementing CI/CD, and storing everything in Git. 

**Happy automating!** 🚀✨

---

**Navigation:** [← Lesson 14](lesson-14-best-practices.md) | [Course Overview](../README.md)