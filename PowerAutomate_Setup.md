# Setting Up Power Automate for ToDo Quick Add

This guide will walk you through setting up a Power Automate flow that allows you to quickly add tasks to Microsoft ToDo using an HTTP trigger.

## Prerequisites

- Microsoft 365 account with access to Power Automate
- Microsoft ToDo app
- Administrator permissions to create HTTP triggers

## Flow Setup Steps

### 1. Create New Flow

1. Log in to Power Automate (https://make.powerautomate.com)
2. Click "New flow"
3. Select "Instant cloud flow"
4. Choose "When an HTTP request is received" as the trigger

### 2. Configure HTTP Trigger

Under who can trigger thh flow choose "anyone".

![image](https://github.com/user-attachments/assets/c5cc8b97-0138-4f0b-b548-f69794ad7655)

Configure the following in the manual trigger:

In the field "Request Body JSON Schema" add the jason code below.
```json
{
    "type": "object",
    "properties": {
        "title": {
            "type": "string"
        },
        "content": {
            "type": "string"
        },
        "dueDateTime": {
            "type": "string"
        },
        "reminderDateTime": {
            "type": "string"
        }
    }
}
```

### 3. Add ToDo Action

1. Click the "+" button below the trigger
2. Search for "Add a to-do (V3)"
   ![image](https://github.com/user-attachments/assets/d6a0233a-f600-4c8b-88dc-235c3c4bcb3b)

3. Configure the following fields:
   - To-do List: Select "Tasks" from dropdown
   - Title: Use dynamic content from trigger body `title`
   - Due Date: Use dynamic content from trigger body `dueDateTime` (optional)
   - Reminder Date-Time: Use dynamic content from trigger body `reminderDateTime` (optional)
   - Body Content: Use dynamic content from trigger body `content`
   - Importance: Choose from Low, Normal, or High
   - Status: Leave as default (Not Started)

### 4. Configure Response
![image](https://github.com/user-attachments/assets/4476ed76-bd37-423d-bc6f-214f7b768878)

1. Add a "Response" action after the ToDo action
2. Set Status Code to 200
3. Body: `Success added task: @{triggerBody()?['title']}`

## Security and Access

- The HTTP trigger URL will be available after saving the flow
- Keep the URL confidential as it allows anyone to add tasks to your ToDo list

## Testing the Flow

1. Save the flow
2. Click "Test" in the top right
3. Select "Manually"
4. Use the following sample JSON payload:
```json
{
    "title": "Test Task",
    "content": "This is a test task",
    "dueDateTime": "2025-01-20T10:00:00Z",
    "reminderDateTime": "2025-01-20T09:00:00Z"
}
```

## Troubleshooting

- If you receive a 401 error, check your flow's permissions
- If the task doesn't appear, verify your ToDo list selection
- Check the run history in Power Automate for detailed error messages

## Usage with AutoHotkey Script

The provided AutoHotkey script uses this flow by:
1. Capturing the CTRL+ALT+T hotkey
2. Prompting for task title and description
3. Sending a POST request to the flow's HTTP endpoint
4. Displaying success/failure notifications
