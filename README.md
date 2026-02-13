<h1 align="center">
  <br>
  <a href="https://github.com/manojxshrestha/">
    <img src="https://github.com/user-attachments/assets/2e4f7e23-444b-4fb2-92f6-c1f425453c11" alt="infoshyt" width="600">
  </a>
  <br>
  infoshyt
  <br>
</h1>

<h4 align="center">OSINT Reconnaissance Tool</h4>


**infoshyt** is an open-source OSINT (Open-Source Intelligence) reconnaissance tool designed to automate the collection and analysis of publicly available information about target domains or IP addresses. It simplifies and accelerates the reconnaissance process by leveraging powerful external tools and APIs, automatically saving results in an organized structure for easy review and sharing.

Perfect tool for security researchers, penetration testers, and cybersecurity enthusiasts.

## 🚀 Key Features

- Automated OSINT data collection
- Supports domains and IP addresses as input
- Smart caching to skip already-processed tasks
- Configurable via `infoshyt.cfg`
- Integration with external tools and APIs
- Output is neatly organized and compressed for easy sharing

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/manojxshrestha/infoshyt.git
cd infoshyt

# Make the scripts executable
chmod +x install.sh
chmod +x configure-infoshyt.sh
chmod +x infoshyt.sh

# Install dependencies
./install.sh
```

## 🔧 API Key Configuration

Run the configuration script:

```bash
./configure-infoshyt.sh
```

Enter your **GitHub** and **GitLab** API keys when prompted.
That's it — you're all set!

## 🚀 Usage

```bash
# Domain scan
./infoshyt.sh -d <domain> [-D]

# Hudson Rock searches (without full OSINT scan)
./infoshyt.sh --username <user>
./infoshyt.sh --email <email>
./infoshyt.sh --phone <number>
```

Results will be saved in:
- Directory: `results/example.com/`
- Archive: `results/example.com/results.tar.gz`

## 🛠️ OSINT Functions

| Function | Description | Output File |
|----------|-------------|-------------|
| `domain_info` | WHOIS lookup, Azure tenants, Scopify | `domain_info_general.txt`, `azure_tenant_domains.txt`, `scopify.txt` |
| `ip_info` | IP WHOIS, geolocation, relations | `ip_*_whois.txt`, `ip_*_location.txt`, `ip_*_relations.txt` |
| `emails` | Email harvesting & password leaks | `emails.txt`, `passwords.txt` |
| `google_dorks` | Automated Google dork queries | `dorks.txt` |
| `github_dorks` | GitHub sensitive dork scanning | `gitdorks.txt` |
| `github_repos` | Repository enumeration & secret detection | `github_company_secrets.json` |
| `metadata` | Metadata extraction from public files | `metadata_results.txt` |
| `apileaks` | API leaks (Postman/Swagger) | `postman_leaks.txt`, `swagger_leaks.txt` |
| `hudson_rock` | Infostealer malware intelligence (domain/username/email/phone) | `hudson_rock.txt`, `hudson_rock_*.json` |
| `third_party_misconfigs` | Third-party service misconfigs | `3rdparts_misconfigurations.txt` |
| `spoof` | SPF/DMARC spoofing check | `spoof.txt` |
| `mail_hygiene` | SPF/DMARC configuration review | `mail_hygiene.txt` |
| `cloud_enum_scan` | Cloud storage enumeration | `cloud_enum.txt` |
| `favicon` | Favicon-based IP discovery | `favicontest.txt` |
| `zonetransfer` | DNS zone transfer check | `zonetransfer.txt` |
| `ip_info` | Retrieves IP data | `ip_*_relations.txt`, `ip_*_whois.txt`, `ip_*_location.txt` |

> Each function can be toggled on/off via `infoshyt.cfg`

## 📂 Output Structure

```
results/
  └── $domain/
        ├── 3rdparts_misconfigurations.txt
        ├── azure_tenant_domains.txt
        ├── cloud_enum.txt
        ├── domain_info_general.txt
        ├── dorks.txt
        ├── emails.txt
        ├── gitdorks.txt
        ├── github_company_secrets.json
        ├── hudson_rock.txt
        ├── hudson_rock_domain.json
        ├── hudson_rock_username.json
        ├── hudson_rock_email.json
        ├── hudson_rock_phone.json
        ├── mail_hygiene.txt
        ├── metadata_results.txt
        ├── passwords.txt
        ├── postman_leaks.txt
        ├── swagger_leaks.txt
        ├── scopify.txt
        ├── spoof.txt
        ├── hosts/
        │     ├── favicontest.txt
        ├── subdomains/
        │     ├── zonetransfer.txt
        └── results.tar.gz
```

## 🐞 Troubleshooting

1. Check `infoshyt.log` for detailed errors
2. Run in debug mode:
   ```bash
   bash -x ./infoshyt.sh -d <domain>
   ```
3. Ensure all external tools and paths in `infoshyt.cfg` are correctly set

## 📄 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
Feel free to modify, distribute, and contribute — just keep this notice intact.

## 🤝 Contributing

- Pull requests are welcome
- Please open issues for bugs, feature requests, or improvements
