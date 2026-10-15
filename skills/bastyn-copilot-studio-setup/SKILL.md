---
name: bastyn-copilot-studio-setup
description: Walks a person through giving Bastyn read-only access to their Microsoft Copilot Studio agent activity. Finds the Application Insights resource, creates a Monitoring Reader identity scoped to that one resource, and lists the admin steps Copilot Studio needs. Use when someone wants to connect Copilot Studio agents to Bastyn.
license: Apache-2.0
metadata:
  version: "1.0.0"
  author: bastyn-labs
---

# Give Bastyn read-only access to your Microsoft Copilot Studio agent activity

You are helping a person connect their Microsoft Copilot Studio agents to Bastyn. Bastyn reads
the agent activity that Microsoft already copies into the person's own Azure Application
Insights resource. Bastyn never sits in the agent's run path and cannot change the person's
resources.

## Rules you must follow

1. Run ONLY the commands in this file. Do not improvise other Azure commands.
2. Before every command that creates or changes something in Azure, show the command and wait for the person to say yes.
3. Scope the new identity to ONE Application Insights resource. Never to a subscription or resource group.
4. The secret appears in the output of the Step 2 command. Show it to the person once, in this conversation, so they can paste it into Bastyn. Never write it to a file, never repeat it later, never send it anywhere else.
5. If a command fails because the person lacks rights, stop and tell them which admin to ask. Do not try to work around it.
6. Be honest about what you could not do. Do not claim a step worked without checking its output.

## What the person needs first

- Azure CLI (`az`) installed and logged in to the right directory: `az login --tenant <tenant id>`.
- Rights to register an app in Microsoft Entra AND to assign a role on the Application Insights resource (Owner or User Access Administrator there). If they have not, they should ask an admin to run these steps.
- Copilot Studio exporting to Application Insights (see "Human steps" at the end). This part cannot be automated.

## Step 1: find the Application Insights resource

```bash
az account show --query "{tenantId:tenantId, subscription:id}" -o json
az resource list --resource-type microsoft.insights/components --query "[].{name:name, resourceGroup:resourceGroup, id:id}" -o table
```

If the resource is in another subscription, ask the person which subscription, run `az account set --subscription <id>`, and list again.

Ask the person which resource Copilot Studio exports to. If they are not sure, the Power Platform
admin centre shows it under Manage > Data export > App Insights (column "Application Insights instance").
Note its full resource id; you need it in Step 2.

## Step 2: create the read-only identity and show the values (needs the person's yes)

Check that `<resource id>` contains `/providers/microsoft.insights/components/`. If it does not, STOP and ask the person; never use a subscription or resource group id as the scope.

Substitute `<resource id>` with the literal id from Step 1 and `<YYYYMMDD>` with today's date, show the command to the person, and run it only after they say yes:

```bash
az ad sp create-for-rbac --name "bastyn-readonly-<YYYYMMDD>" --role "Monitoring Reader" --scopes "<resource id>" --years 1 --query "{tenant_id:tenant, client_id:appId, client_secret:password}" -o json
```

This prints three values once. Show the output to the person in this conversation, together with a fourth value, the resource id from Step 1. Label them Tenant id, Client id, Client secret and Resource id, and tell the person to paste all four into Bastyn (Live Monitoring > Copilot Studio). The client secret cannot be shown again. Do NOT run this command a second time (it would create another identity). Do not copy the output to a file or repeat the secret later.

If the secret is lost or rejected, a new one is made with `az ad app credential reset --id <client id> --years 1 --query password -o tsv`. This also needs the person's yes.

The role is `Monitoring Reader`, scoped to that one resource. It can read, it cannot change your
resources. (It can read the resource's connection string; Bastyn does not use it.)

Do not ask the person for, or look for, any other value. Bastyn works out the query application id itself.

## Step 3: tell the person what to do next

Tell them: "Paste the four values into Bastyn and press **Check connection**. A new role can take
a minute or two to apply, so if the first check says Bastyn is not allowed yet, Bastyn retries by itself for about a minute; if it still fails after that, press Check connection again."

## Human steps (cannot be automated; tell the person to do them in a browser)

Copilot Studio only writes activity to Application Insights after an admin switches the export on.

1. Open the Power Platform admin centre (admin.powerplatform.microsoft.com). A multi-factor sign-in prompt can appear first; the person must complete it.
2. Manage > Data export > **App Insights** tab > **New data export**.
3. Screen 1: name the package and choose **Copilot Studio (preview)**.
4. Screen 2: choose the managed environment (only managed environments are listed).
5. Screen 3: choose the Azure subscription, the resource group, and the Application Insights resource from Step 1.
6. Screen 4: review, then **Create**. The package should then show status **Connected**.
7. Prerequisites that commonly block it: the environment must be a Managed Environment; the Application Insights resource must have key-based ingestion ("Local authentication") ON; the Copilot Studio billing plan region must equal the environment's region; agents only answer once the plan is attached.
8. Have a conversation with an agent. The first rows usually appear within about 10 minutes; Microsoft documents up to 24 hours.

Not logged by Microsoft, so invisible to Bastyn: unauthenticated agents, multi-tenant agents, declarative agents, and environments that are not managed. This feature is in Microsoft public preview.
