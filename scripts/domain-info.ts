#!/usr/bin/env bun

import { execSync } from 'child_process';

interface DomainReport {
  domain: string;
  dns: {
    a: string[];
    aaaa: string[];
    mx: Array<{ priority: number; server: string }>;
    txt: string[];
    ns: string[];
    cname: string | null;
    soa: string | null;
  };
  whois: {
    registrar: string | null;
    createdDate: string | null;
    expiryDate: string | null;
    nameServers: string[];
    status: string[];
  };
  ssl: {
    issuer: string | null;
    validFrom: string | null;
    validTo: string | null;
    subject: string | null;
    san: string[];
  };
  security: {
    dnssec: boolean;
    spf: string | null;
    dmarc: string | null;
    dkim: string | null;
  };
  performance: {
    queryTime: number;
    ttl: number | null;
  };
}

// ANSI color codes
const colors = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  dim: '\x1b[2m',

  // Standard colors
  black: '\x1b[30m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m',

  // Bright colors
  brightBlack: '\x1b[90m',
  brightRed: '\x1b[91m',
  brightGreen: '\x1b[92m',
  brightYellow: '\x1b[93m',
  brightBlue: '\x1b[94m',
  brightMagenta: '\x1b[95m',
  brightCyan: '\x1b[96m',
  brightWhite: '\x1b[97m',

  // Background colors
  bgBlack: '\x1b[40m',
  bgRed: '\x1b[41m',
  bgGreen: '\x1b[42m',
  bgYellow: '\x1b[43m',
  bgBlue: '\x1b[44m',
  bgMagenta: '\x1b[45m',
  bgCyan: '\x1b[46m',
  bgWhite: '\x1b[47m',
};

function exec(cmd: string): string {
  try {
    return execSync(cmd, { encoding: 'utf-8', stdio: ['pipe', 'pipe', 'pipe'] }).trim();
  } catch (e) {
    return '';
  }
}

function parseDNS(domain: string): DomainReport['dns'] {
  const dns = {
    a: [] as string[],
    aaaa: [] as string[],
    mx: [] as Array<{ priority: number; server: string }>,
    txt: [] as string[],
    ns: [] as string[],
    cname: null as string | null,
    soa: null as string | null,
  };

  // A records
  const aOutput = exec(`dig +short A ${domain}`);
  if (aOutput) {
    dns.a = aOutput.split('\n').filter(line => line && /^\d+\.\d+\.\d+\.\d+$/.test(line));
  }

  // AAAA records
  const aaaaOutput = exec(`dig +short AAAA ${domain}`);
  if (aaaaOutput) {
    dns.aaaa = aaaaOutput.split('\n').filter(line => line && line.includes(':'));
  }

  // MX records
  const mxOutput = exec(`dig +short MX ${domain}`);
  if (mxOutput) {
    dns.mx = mxOutput.split('\n')
      .filter(line => line)
      .map(line => {
        const [priority, server] = line.split(' ');
        return { priority: parseInt(priority), server: server.replace(/\.$/, '') };
      });
  }

  // TXT records
  const txtOutput = exec(`dig +short TXT ${domain}`);
  if (txtOutput) {
    dns.txt = txtOutput.split('\n')
      .filter(line => line)
      .map(line => line.replace(/^"|"$/g, ''));
  }

  // NS records
  const nsOutput = exec(`dig +short NS ${domain}`);
  if (nsOutput) {
    dns.ns = nsOutput.split('\n')
      .filter(line => line)
      .map(line => line.replace(/\.$/, ''));
  }

  // CNAME record
  const cnameOutput = exec(`dig +short CNAME ${domain}`);
  if (cnameOutput) {
    dns.cname = cnameOutput.split('\n')[0]?.replace(/\.$/, '') || null;
  }

  // SOA record
  const soaOutput = exec(`dig +short SOA ${domain}`);
  if (soaOutput) {
    dns.soa = soaOutput;
  }

  return dns;
}

function parseWhois(domain: string): DomainReport['whois'] {
  const whoisOutput = exec(`whois ${domain}`);
  const whois = {
    registrar: null as string | null,
    createdDate: null as string | null,
    expiryDate: null as string | null,
    nameServers: [] as string[],
    status: [] as string[],
  };

  if (!whoisOutput) return whois;

  // Registrar
  const registrarMatch = whoisOutput.match(/Registrar:\s*(.+)/i);
  if (registrarMatch) whois.registrar = registrarMatch[1].trim();

  // Created date
  const createdMatch = whoisOutput.match(/Creation Date:\s*(.+)/i);
  if (createdMatch) whois.createdDate = createdMatch[1].trim();

  // Expiry date
  const expiryMatch = whoisOutput.match(/Registry Expiry Date:\s*(.+)/i) ||
                      whoisOutput.match(/Expiration Date:\s*(.+)/i);
  if (expiryMatch) whois.expiryDate = expiryMatch[1].trim();

  // Name servers
  const nsMatches = whoisOutput.matchAll(/Name Server:\s*(.+)/gi);
  for (const match of nsMatches) {
    whois.nameServers.push(match[1].trim().toLowerCase());
  }

  // Status
  const statusMatches = whoisOutput.matchAll(/Domain Status:\s*(.+)/gi);
  for (const match of statusMatches) {
    whois.status.push(match[1].trim());
  }

  return whois;
}

function parseSSL(domain: string): DomainReport['ssl'] {
  const ssl = {
    issuer: null as string | null,
    validFrom: null as string | null,
    validTo: null as string | null,
    subject: null as string | null,
    san: [] as string[],
  };

  const sslOutput = exec(`echo | openssl s_client -servername ${domain} -connect ${domain}:443 2>/dev/null | openssl x509 -noout -text 2>/dev/null`);

  if (!sslOutput) return ssl;

  // Issuer
  const issuerMatch = sslOutput.match(/Issuer:.*CN\s*=\s*([^,\n]+)/);
  if (issuerMatch) ssl.issuer = issuerMatch[1].trim();

  // Valid from
  const validFromMatch = sslOutput.match(/Not Before\s*:\s*(.+)/);
  if (validFromMatch) ssl.validFrom = validFromMatch[1].trim();

  // Valid to
  const validToMatch = sslOutput.match(/Not After\s*:\s*(.+)/);
  if (validToMatch) ssl.validTo = validToMatch[1].trim();

  // Subject
  const subjectMatch = sslOutput.match(/Subject:.*CN\s*=\s*([^,\n]+)/);
  if (subjectMatch) ssl.subject = subjectMatch[1].trim();

  // SAN
  const sanMatch = sslOutput.match(/DNS:([^\n]+)/);
  if (sanMatch) {
    ssl.san = sanMatch[1].split('DNS:')
      .map(s => s.trim().replace(/,$/, ''))
      .filter(s => s);
  }

  return ssl;
}

function parseSecurity(domain: string, dns: DomainReport['dns']): DomainReport['security'] {
  const security = {
    dnssec: false,
    spf: null as string | null,
    dmarc: null as string | null,
    dkim: null as string | null,
  };

  // DNSSEC
  const dnssecOutput = exec(`dig +dnssec ${domain} | grep -i "ad;"`);
  security.dnssec = !!dnssecOutput;

  // SPF (in TXT records)
  const spfRecord = dns.txt.find(record => record.startsWith('v=spf1'));
  if (spfRecord) security.spf = spfRecord;

  // DMARC
  const dmarcOutput = exec(`dig +short TXT _dmarc.${domain}`);
  if (dmarcOutput) {
    security.dmarc = dmarcOutput.replace(/^"|"$/g, '');
  }

  // DKIM (check common selectors)
  const selectors = ['default', 'google', 'k1', 'selector1', 'selector2'];
  for (const selector of selectors) {
    const dkimOutput = exec(`dig +short TXT ${selector}._domainkey.${domain}`);
    if (dkimOutput && dkimOutput.includes('v=DKIM1')) {
      security.dkim = `${selector}._domainkey.${domain}`;
      break;
    }
  }

  return security;
}

async function getDomainInfo(domain: string): Promise<DomainReport> {
  const startTime = Date.now();

  const dns = parseDNS(domain);
  const whois = parseWhois(domain);
  const ssl = parseSSL(domain);
  const security = parseSecurity(domain, dns);

  const queryTime = Date.now() - startTime;

  // Get TTL from dig output
  const ttlOutput = exec(`dig ${domain} | grep -E "^${domain}\\." | head -1`);
  const ttlMatch = ttlOutput.match(/\d+/);
  const ttl = ttlMatch ? parseInt(ttlMatch[0]) : null;

  return {
    domain,
    dns,
    whois,
    ssl,
    security,
    performance: {
      queryTime,
      ttl,
    },
  };
}

function formatReport(report: DomainReport): string {
  const { domain, dns, whois, ssl, security, performance } = report;
  const c = colors;

  let output = '\n';

  // Header
  const boxWidth = 78;
  const contentWidth = boxWidth - 2; // Subtract border characters
  const title = 'DOMAIN INTELLIGENCE REPORT';

  output += `${c.bold}${c.brightCyan}╔${'═'.repeat(boxWidth)}╗${c.reset}\n`;
  output += `${c.bold}${c.brightCyan}║${c.reset} ${c.bold}${c.brightWhite}${title}${c.reset}${' '.repeat(contentWidth - title.length)} ${c.bold}${c.brightCyan}║${c.reset}\n`;
  output += `${c.bold}${c.brightCyan}║${c.reset} ${c.brightYellow}${domain}${c.reset}${' '.repeat(contentWidth - domain.length)} ${c.bold}${c.brightCyan}║${c.reset}\n`;
  output += `${c.bold}${c.brightCyan}╚${'═'.repeat(boxWidth)}╝${c.reset}\n\n`;

  // DNS Records Section
  output += `${c.bold}${c.brightMagenta}┌─ DNS RECORDS${c.reset}\n`;

  if (dns.a.length > 0) {
    output += `${c.bold}${c.cyan}│ A Records${c.reset}\n`;
    dns.a.forEach(ip => {
      output += `${c.dim}│${c.reset}   ${c.green}→${c.reset} ${ip}\n`;
    });
  }

  if (dns.aaaa.length > 0) {
    output += `${c.bold}${c.cyan}│ AAAA Records${c.reset}\n`;
    dns.aaaa.forEach(ip => {
      output += `${c.dim}│${c.reset}   ${c.green}→${c.reset} ${ip}\n`;
    });
  }

  if (dns.mx.length > 0) {
    output += `${c.bold}${c.cyan}│ MX Records${c.reset}\n`;
    dns.mx.forEach(mx => {
      output += `${c.dim}│${c.reset}   ${c.green}→${c.reset} [${c.yellow}${mx.priority}${c.reset}] ${mx.server}\n`;
    });
  }

  if (dns.ns.length > 0) {
    output += `${c.bold}${c.cyan}│ NS Records${c.reset}\n`;
    dns.ns.forEach(ns => {
      output += `${c.dim}│${c.reset}   ${c.green}→${c.reset} ${ns}\n`;
    });
  }

  if (dns.cname) {
    output += `${c.bold}${c.cyan}│ CNAME${c.reset}\n`;
    output += `${c.dim}│${c.reset}   ${c.green}→${c.reset} ${dns.cname}\n`;
  }

  if (dns.txt.length > 0) {
    output += `${c.bold}${c.cyan}│ TXT Records${c.reset}\n`;
    dns.txt.forEach(txt => {
      const truncated = txt.length > 68 ? txt.substring(0, 65) + '...' : txt;
      output += `${c.dim}│${c.reset}   ${c.green}→${c.reset} ${c.dim}${truncated}${c.reset}\n`;
    });
  }

  if (dns.soa) {
    output += `${c.bold}${c.cyan}│ SOA${c.reset}\n`;
    const soaTruncated = dns.soa.length > 68 ? dns.soa.substring(0, 65) + '...' : dns.soa;
    output += `${c.dim}│${c.reset}   ${c.dim}${soaTruncated}${c.reset}\n`;
  }

  output += `${c.dim}└${'─'.repeat(78)}${c.reset}\n\n`;

  // WHOIS Section
  output += `${c.bold}${c.brightMagenta}┌─ WHOIS INFORMATION${c.reset}\n`;

  if (whois.registrar) {
    output += `${c.bold}${c.cyan}│ Registrar${c.reset}\n`;
    output += `${c.dim}│${c.reset}   ${whois.registrar}\n`;
  }

  if (whois.createdDate) {
    output += `${c.bold}${c.cyan}│ Created${c.reset}\n`;
    output += `${c.dim}│${c.reset}   ${whois.createdDate}\n`;
  }

  if (whois.expiryDate) {
    output += `${c.bold}${c.cyan}│ Expires${c.reset}\n`;
    const expiryDate = new Date(whois.expiryDate);
    const daysUntilExpiry = Math.floor((expiryDate.getTime() - Date.now()) / (1000 * 60 * 60 * 24));
    const expiryColor = daysUntilExpiry < 30 ? c.red : daysUntilExpiry < 90 ? c.yellow : c.green;
    output += `${c.dim}│${c.reset}   ${expiryColor}${whois.expiryDate}${c.reset} ${c.dim}(${daysUntilExpiry} days)${c.reset}\n`;
  }

  if (whois.nameServers.length > 0) {
    output += `${c.bold}${c.cyan}│ Name Servers${c.reset}\n`;
    whois.nameServers.forEach(ns => {
      output += `${c.dim}│${c.reset}   ${c.green}→${c.reset} ${ns}\n`;
    });
  }

  if (whois.status.length > 0) {
    output += `${c.bold}${c.cyan}│ Status${c.reset}\n`;
    whois.status.slice(0, 3).forEach(status => {
      output += `${c.dim}│${c.reset}   ${c.dim}${status}${c.reset}\n`;
    });
  }

  output += `${c.dim}└${'─'.repeat(78)}${c.reset}\n\n`;

  // SSL Certificate Section
  if (ssl.issuer || ssl.validTo) {
    output += `${c.bold}${c.brightMagenta}┌─ SSL/TLS CERTIFICATE${c.reset}\n`;

    if (ssl.issuer) {
      output += `${c.bold}${c.cyan}│ Issuer${c.reset}\n`;
      output += `${c.dim}│${c.reset}   ${ssl.issuer}\n`;
    }

    if (ssl.subject) {
      output += `${c.bold}${c.cyan}│ Subject${c.reset}\n`;
      output += `${c.dim}│${c.reset}   ${ssl.subject}\n`;
    }

    if (ssl.validFrom) {
      output += `${c.bold}${c.cyan}│ Valid From${c.reset}\n`;
      output += `${c.dim}│${c.reset}   ${ssl.validFrom}\n`;
    }

    if (ssl.validTo) {
      output += `${c.bold}${c.cyan}│ Valid To${c.reset}\n`;
      const validToDate = new Date(ssl.validTo);
      const daysUntilExpiry = Math.floor((validToDate.getTime() - Date.now()) / (1000 * 60 * 60 * 24));
      const expiryColor = daysUntilExpiry < 30 ? c.red : daysUntilExpiry < 90 ? c.yellow : c.green;
      output += `${c.dim}│${c.reset}   ${expiryColor}${ssl.validTo}${c.reset} ${c.dim}(${daysUntilExpiry} days)${c.reset}\n`;
    }

    if (ssl.san.length > 0) {
      output += `${c.bold}${c.cyan}│ Subject Alternative Names${c.reset}\n`;
      ssl.san.slice(0, 5).forEach(san => {
        output += `${c.dim}│${c.reset}   ${c.green}→${c.reset} ${san}\n`;
      });
      if (ssl.san.length > 5) {
        output += `${c.dim}│${c.reset}   ${c.dim}... and ${ssl.san.length - 5} more${c.reset}\n`;
      }
    }

    output += `${c.dim}└${'─'.repeat(78)}${c.reset}\n\n`;
  }

  // Security Section
  output += `${c.bold}${c.brightMagenta}┌─ SECURITY${c.reset}\n`;

  output += `${c.bold}${c.cyan}│ DNSSEC${c.reset}\n`;
  output += `${c.dim}│${c.reset}   ${security.dnssec ? `${c.green}✓ Enabled${c.reset}` : `${c.red}✗ Disabled${c.reset}`}\n`;

  output += `${c.bold}${c.cyan}│ SPF${c.reset}\n`;
  if (security.spf) {
    const spfTruncated = security.spf.length > 68 ? security.spf.substring(0, 65) + '...' : security.spf;
    output += `${c.dim}│${c.reset}   ${c.green}✓${c.reset} ${c.dim}${spfTruncated}${c.reset}\n`;
  } else {
    output += `${c.dim}│${c.reset}   ${c.red}✗ Not configured${c.reset}\n`;
  }

  output += `${c.bold}${c.cyan}│ DMARC${c.reset}\n`;
  if (security.dmarc) {
    const dmarcTruncated = security.dmarc.length > 68 ? security.dmarc.substring(0, 65) + '...' : security.dmarc;
    output += `${c.dim}│${c.reset}   ${c.green}✓${c.reset} ${c.dim}${dmarcTruncated}${c.reset}\n`;
  } else {
    output += `${c.dim}│${c.reset}   ${c.red}✗ Not configured${c.reset}\n`;
  }

  output += `${c.bold}${c.cyan}│ DKIM${c.reset}\n`;
  if (security.dkim) {
    output += `${c.dim}│${c.reset}   ${c.green}✓${c.reset} ${security.dkim}\n`;
  } else {
    output += `${c.dim}│${c.reset}   ${c.yellow}? Not detected${c.reset} ${c.dim}(checked common selectors)${c.reset}\n`;
  }

  output += `${c.dim}└${'─'.repeat(78)}${c.reset}\n\n`;

  // Performance Section
  output += `${c.bold}${c.brightMagenta}┌─ PERFORMANCE${c.reset}\n`;

  output += `${c.bold}${c.cyan}│ Query Time${c.reset}\n`;
  output += `${c.dim}│${c.reset}   ${performance.queryTime}ms\n`;

  if (performance.ttl) {
    output += `${c.bold}${c.cyan}│ TTL${c.reset}\n`;
    output += `${c.dim}│${c.reset}   ${performance.ttl}s\n`;
  }

  output += `${c.dim}└${'─'.repeat(78)}${c.reset}\n\n`;

  return output;
}

// Main
const domain = process.argv[2];

if (!domain) {
  console.error(`${colors.red}Usage: domain-info <domain>${colors.reset}`);
  process.exit(1);
}

console.log(`${colors.dim}Gathering domain intelligence for ${colors.brightYellow}${domain}${colors.dim}...${colors.reset}`);

const report = await getDomainInfo(domain);
console.log(formatReport(report));
