# katacoda-scenarios

## KSM Scenarios Feature Matrix

This table provides a quick overview of the key features covered in each Keeper Secrets Manager (KSM) SDK and integration tutorial available in this repository.

| Feature                        | Python SDK | Java SDK | .NET SDK | Go SDK   | JavaScript SDK | Ansible | KSM CLI |
|--------------------------------|------------|----------|----------|----------|----------------|---------|---------|
| **Setup & Installation**       | ✅         | ✅       | ✅       | ✅       | ✅             | ✅      | ✅      |
| **Initial Connection/Auth**    | ✅         | ✅       | ✅       | ✅       | ✅             | ✅      | ✅      |
|  - One-Time Token              | ✅         | ✅       | ✅       | ✅       | ✅             | ✅      | ✅      |
|  - Config File (ksm-config.json)| ✅         | ✅       | ✅       | ✅       | ✅             | ✅      | ✅      |
| **List All Shared Records**    | ✅         | ✅       | ✅       | ✅       | ✅             | ➖      | ✅      |
| **Get Specific Record by UID** | ✅         | ✅       | ✅       | ✅       | ➖             | ✅      | ✅      |
| **Get Specific Record by Title**| ✅         | ✅       | ✅       | ✅       | ➖             | ➖      | 🛠️      |
| **Access Record Fields**       | ✅         | ✅       | ✅       | ✅       | ✅             | ✅      | ✅      |
|  - Standard Fields             | ✅         | ✅       | ✅       | ✅       | ✅             | ✅      | ✅      |
|  - Custom Fields               | ✅         | ✅       | ✅       | ✅       | ➖             | ➖      | ✅      |
|  - Notes                       | ✅         | ✅       | ✅       | ✅       | ✅             | ➖      | ➖      |
| **Record Creation**            | ✅         | ✅       | ✅       | ✅       | ✅             | ➖      | ➖      |
|  - With Various Field Types    | ✅         | ✅       | ✅       | ✅       | ✅             | ➖      | ➖      |
| **Folder Creation/Mgmt.**      | ➖         | ✅       | ➖       | ➖             | ➖             | ➖      | ➖      |
| **File Upload to Record**      | ✅         | ✅       | ✅       | ✅       | ➖             | ➖      | ✅      |
| **File Download from Record**  | ➖         | ✅       | ➖       | ➖             | ➖             | ✅      | ✅      |
| **Client-Side Caching**        | ✅         | ✅       | ✅       | ✅       | ➖             | ✅      | ➖      |
| **In-Memory Configuration**    | ✅         | ✅       | ✅       | ✅       | ➖             | ✅      | ✅      |
| **CLI/Tool Specific Features** | N/A        | N/A      | N/A      | N/A      | N/A            | ✅      | ✅      |

**Legend:**
- ✅: Feature is explicitly covered or conceptually explained in the tutorial.
- ➖: Feature is not explicitly covered or is not applicable to the tool's primary focus in the tutorial.
- 🛠️: Feature is partially covered, covered via tool-specific means, or conceptually discussed.

**Notes:**
- All SDKs inherently support the full range of KSM capabilities (listing, getting, creating, updating, deleting records/folders/files). The table reflects what is *emphasized and demonstrated within the tutorial steps* of this repository.
- For CLI tools (KSM CLI), many features are available through their rich command sets, even if not every single one is part of a specific tutorial step.
- The JavaScript SDK tutorial is less comprehensive in this repository compared to the others as of the last major update, hence more ➖ entries.

This matrix should help users navigate to the scenario that best fits their learning goals or integration needs.