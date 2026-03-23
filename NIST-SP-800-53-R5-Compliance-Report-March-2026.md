# NIST SP 800-53 R5 Compliance Report

**Framework:** NIST SP 800-53 Revision 5  
**Platform:** Microsoft Defender for Cloud — Azure Regulatory Compliance  
**Report Date:** March 16, 2026  
**Status:** 🟡 In Progress

---

## Compliance Summary

| Metric | Value |
|---|---|
| **Controls Passing** | 541 |
| **Controls Assessed** | 586 |
| **Controls Failing** | 45 |
| **Pass Rate** | 92.3% |

### What This Score Means

The **541/586** ratio reflects the number of NIST SP 800-53 R5 controls that are currently in a **Passed** state versus the total number of controls that Microsoft Defender for Cloud was able to assess against our environment.

> ⚠️ **Important:** 586 is **not** the full NIST SP 800-53 R5 control catalog. The complete catalog contains 1,000+ controls. Defender for Cloud evaluates only the subset it has built-in policy mappings for **and** that are relevant to the resource types deployed in this environment.

---

## How Controls Are Scored

A NIST control is marked as **Passed** only when **all** recommendations mapped to that control are healthy across **all** assessed resources. If even one resource fails one recommendation mapped to a control, the entire control is marked **Failed**.

### Example

```
NIST Control SI-2 (Flaw Remediation)
├── Recommendation A → 47 / 48 resources passing
├── Recommendation B → 48 / 48 resources passing
└── Result → Control SI-2 = FAILED  ← due to 1 resource in Recommendation A
```

This means a single non-compliant resource can cause **multiple controls to fail** if that resource maps to several controls simultaneously. The inverse is also true — remediating a single High Risk resource can flip **multiple controls** back to Passed in one action.

---

## Remediation Strategy

Our active remediation effort is scoped to items with a **Risk Level of High or Critical** as assessed by Microsoft Defender for Cloud. Risk Level is a dynamic, context-aware score that accounts for:

- Network exposure and public accessibility
- Compensating controls already in place
- Attack path feasibility
- Asset sensitivity and data classification
- Lateral movement potential

> Items with a lower Risk Level — even if their Recommendation Severity is rated High by Microsoft — indicate that existing environmental controls already substantially mitigate real-world exploitability. These are deferred and reviewed periodically.

---

## High Risk Findings — Accepted Risk / Out of Scope

The following High Risk Level findings have been reviewed and are **not being remediated** in the current cycle. These fall into two categories:

1. **Azure-specific configurations that are not applicable to our deployment model** — these recommendations require Azure-native features or settings that our environment does not use or require.

2. **Database, networking, and storage account configurations that are intentionally left to end users** — these are architectural decisions that individual organizations and their security teams are responsible for based on their own policies, data classification requirements, and compliance obligations. We do not prescribe or enforce these configurations on behalf of our users.

### Accepted Risk Register

| Finding | Risk Level | Rationale |
|---|---|---|
| SQL servers should have an Azure Active Directory administrator provisioned | High | Database security configuration is left to user organization policy |
| Public network access on Azure SQL Database should be disabled | High | Network topology and public access decisions are user-defined |
| Storage accounts should restrict network access  | High | Storage account network configuration is left to user organization policy |
| Azure Defender for DNS should be enabled | High | Azure-specific feature not required in our deployment model |
| Azure Defender for Resource Manager should be enabled  | High | Azure-specific feature not required in our deployment model |

> **Note:** This table should be updated as findings are reviewed each compliance cycle. Add or remove rows to reflect the current accepted risk posture.
The complete findings to include the exact compliance controls are maintained in [accepted-nist-risk-register-March-16-2026.csv](./accepted-nist-risk-register-March-16-2026.csv) and updated each compliance cycle.

---

## Framework Context

NIST SP 800-53 R5 is a **risk-based framework** — it does not mandate that all controls be treated with equal urgency or that every recommendation be remediated without exception. The framework explicitly allows for:

- **Compensating controls** — alternative measures that achieve equivalent protection
- **Documented exceptions** — formally accepted risks with documented rationale and ownership
- **Tailoring** — organizations may scope controls to what is relevant to their system boundary and operational environment

The findings listed in the Accepted Risk Register above are treated as **documented exceptions** under this provision. Each exception is owned by the respective user organization and falls outside our system boundary.

---

## Compliance Trend

| Date | Passing | Assessed | Pass Rate |
|---|---|---|---|
| March 16, 2026 | 541 | 586 | 92.3% |
| *(previous period)* | — | — | — |

> Update this table each compliance review cycle to demonstrate continuous improvement over time. A positive trend in the pass rate is a key indicator for auditors, often more meaningful than a single point-in-time score.

---

## Next Steps

- [ ] Continue remediating all **High and Critical Risk Level** findings within our system boundary
- [ ] Review accepted risk register quarterly or when environmental posture changes
- [ ] Re-evaluate deferred findings if Risk Level is elevated by Defender for Cloud
- [ ] Update compliance trend table each reporting period
- [ ] Ensure compensating controls for accepted risk items are documented and current

---

## References

- [NIST SP 800-53 R5 Control Catalog](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [Microsoft Defender for Cloud — Regulatory Compliance](https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard)
- [Microsoft Defender for Cloud — Risk Prioritization](https://learn.microsoft.com/en-us/azure/defender-for-cloud/risk-prioritization)
- [Attack Path Analysis in Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/how-to-manage-attack-path)
- [NIST SP 800-53 R5 — Tailoring Guidance](https://csrc.nist.gov/publications/detail/sp/800-53b/final)
