# Running Global Payroll Test Scripts

This guide explains how to correctly set up your environment and execute the primary payroll outbound generation tests.

---

## 1. Environment Setup

Before running any test scripts, you **must initialize the required environment variables and configuration**:

```bash
./setup.sh env=anishbox employer_id=9649a8ac-edcf-492d-a9c3-6f592e9dc5d5
```

> ℹ️ Replace `env` and `employer_id` values if you are testing with different environments or employers.

This will configure all necessary credentials, endpoints, and context required for executing the tests.

---

## 2. Navigate to the Test Directory

To run the payroll outbound generation test, change into the relevant folder:

```bash
cd createPayroll
```

---

## 3. Run the Outbound Generation Script

Within the `createPayroll` directory, you will find the script that generates outbound payroll data. Change into the outbound script folder (if not already there) and run:

```bash
cd generate-outbound
./run.sh
```

- `./run.sh` will start the outbound payroll generation process using the environment and employer configuration set in step 1.
- All required dependencies and needed files should be available in this directory.

---

## Summary of Commands

```bash
# 1. Setup environment and employer:
./setup.sh env=anishbox employer_id=9649a8ac-edcf-492d-a9c3-6f592e9dc5d5

# 2. Go to the payroll script folder:
cd createPayroll

# 3. Enter the outbound folder and run the process:
cd generate-outbound
./run.sh
```

---

## Troubleshooting

- If you encounter permission issues, ensure your scripts are executable:  
  `chmod +x setup.sh createPayroll/generate-outbound/run.sh`
- If you see missing dependency errors, check for a `README.md` or dependency manifest in the folder and follow install instructions.
- Double-check your `env` and `employer_id` values for typos.

---

If you have any issues, please open an issue or contact the repository maintainers.
