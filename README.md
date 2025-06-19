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
./install.sh
```
# Make the script executable
```bash
chmod +x configure_infoshyt.sh
chmod +x infoshyt.sh
```

## 🔧 API Key Configuration

Run the configuration script:

```bash
./configure_infoshyt.sh
```

Enter your **GitHub** and **GitLab** API keys when prompted.
That's it — you're all set!

## 🚀 Usage

```bash
./infoshyt.sh -d <domain_or_ip> [-D]
```

Results will be saved in:
- Directory: `results/example.com/osint/`
- Archive: `results/example.com/results.tar.gz`

## 🛠️ OSINT Functions

| Function | Description | Output File |
|----------|-------------|-------------|
| `google_dorks` | Finds Google dorks for the target | `dorks.txt` |
| `github_dorks` | Scans GitHub for sensitive dorks | `gitdorks.txt` |
| `github_repos` | Extracts secrets from GitHub repositories | `github_company_secrets.json` |
| `metadata` | Harvests metadata from public files | `metadata_results.txt` |
| `apileaks` | Detects API key leaks via Postman/Swagger | `postman_leaks.txt`, `swagger_leaks.txt` |
| `emails` | Finds email addresses and potential leaks | `emails.txt`, `passwords.txt` |
| `domain_info` | Gathers WHOIS and tenant domains | `domain_info_general.txt`, `azure_tenant_domains.txt` |
| `third_party_misconfigs` | Identifies misconfigured services | `3rdparts_misconfigurations.txt` |
| `spoof` | Detects spoofable domains | `spoof.txt` |
| `ip_info` | Retrieves IP data | `ip_*_relations.txt`, `ip_*_whois.txt`, `ip_*_location.txt` |

> Each function can be toggled on/off via `infoshyt.cfg`

## 📂 Output Structure

```
results/
  └── $domain/
        ├── osint/
        │     ├── 3rdparts_misconfigurations.txt
        │     ├── azure_tenant_domains.txt
        │     ├── domain_info_general.txt
        │     ├── dorks.txt
        │     ├── emails.txt
        │     ├── gitdorks.txt
        │     ├── github_company_secrets.json
        │     ├── metadata_results.txt
        │     ├── postman_leaks.txt
        │     ├── swagger_leaks.txt
        │     ├── scopify.txt
        │     ├── spoof.txt
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
