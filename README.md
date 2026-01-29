# Insurance Claim Management System (ICMS)

A robust, Flutter Web application backed by Supabase for managing hospital insurance claims. This project features a simulated Role-Based Access Control (RBAC) system, ensuring secure and logical workflows for both Applicants (Users) and Processors (Admins).

## 📸 Screenshots
<img width="2879" height="1550" alt="image" src="https://github.com/user-attachments/assets/b20d386b-dd72-48ca-b721-fb00004d5a60" />
<img width="2874" height="1456" alt="image" src="https://github.com/user-attachments/assets/62ee6367-b2c6-48a5-8570-f2e8cd050737" />
<img width="2872" height="613" alt="image" src="https://github.com/user-attachments/assets/4695a994-e791-4cd9-8d87-f78d31ba2a4f" />


## 🚀 Live Demo

[**View Live Deployment**](https://i-c-m-s-git-main-shresth1822s-projects.vercel.app/)

## ✨ Key Features

### 🎨 🎨 User Experience

Clean, modern, and professional UI optimized for clarity and usability.
Responsive layout for web browsers.
Contextual guidance for Bills, Advances, and Settlements.


### 👥 Role-Based Access Control (Simulated)

Switch roles instantly using the toggle in the top-right corner to test different workflows.

- **User Mode (Applicant)**:
  - Create new claims (Status locked to `Draft`).
  - Add medical bills to draft claims.
  - Submit claims for approval.
  - _Restricted_: Cannot edit approved claims or delete settled items.
- **Admin Mode (Processor)**:
  - View all submitted claims.
  - Approve or Reject claims.
  - Manage **Settlements** and **Advances**.
  - Automatic status updates (`Approved` -> `Partially Settled` -> `Settled`).

### ⚙️ Robust Business Logic

- **Lifecycle Management**: Claims follow a strict state machine: `Draft → Submitted → Approved / Rejected → Partially Settled → Settled`.
- **Financial Integrity**: Real-time calculation of Total Bill, Paid Amount, and Pending Balance.
- **Automatic Status**: The system automatically transitions claims to `Settled` when the balance reaches zero, and reverts to `Partially Settled` if a payment is deleted.

## 🛠 Tech Stack

- **Frontend**: Flutter (3.x)
- **State Management**: Riverpod (Providers & Notifiers)
- **Backend**: Supabase (PostgreSQL & Realtime)
- **Deployment**: Vercel (Static Web Hosting)

## 📦 Setup Instructions

### Prerequisites

- Flutter SDK (3.x+)
- Supabase Project

### 1. Clone the repository

```bash
git clone https://github.com/Shresth1822/i-c-m-s.git
cd i-c-m-s
```

### 2. Configure Environment

Create a `.env` file in the root directory:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 3. Database Setup

Run the SQL script located in `supabase/schema.sql` in your Supabase SQL Editor to create the necessary tables.

### 4. Run Locally

```bash
flutter pub get
flutter run -d chrome
```

## 🧪 Evaluator Walkthrough

1.  **Start as User**:
    - Toggle to **User**.
    - Click **+ New Claim** -> Save (Status: Draft).
    - Open Claim -> Add Bills ($500).
    - Click **Submit Claim**.
2.  **Switch to Admin**:
    - Toggle to **Admin**.
    - Open Claim (Status: Submitted).
    - Click **Approve**.
    - Add **Advance** ($200) -> Status becomes `Partially Settled`.
    - Add **Settlement** ($300) -> Status becomes `Settled`.
3.  **Verify Logic**:
    - Try deleting the $300 settlement.
    - Status correctly reverts to `Partially Settled`.

## 📌 Assignment Alignment

This project satisfies all assignment requirements:
- Creation and management of insurance claims
- Bills, advances, settlements, and pending amount handling
- Complete claim status workflow
- Automatic calculations
- Dashboard view of claims
- Public deployment with live URL

---



