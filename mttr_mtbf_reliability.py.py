import pandas as pd
import mysql.connector

# ─────────────────────────────────────────────
# Incident Operations Analytics
# MTTR, MTBF & Reliability Calculation
# ─────────────────────────────────────────────

# Step 1: MySQL Connection
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='YOUR_PASSWORD',
    database='Incident_Operations_analytics'
)

# Step 2: Load Resolved Incidents
query = """
SELECT *
FROM incident_analytics
WHERE status = 'Resolved'
"""

df = pd.read_sql(query, conn)
conn.close()

print(f"\nTotal incidents loaded: {len(df)}")
print(df.head())

# ─────────────────────────────────────────────
# MTTR (Mean Time To Resolution)
# ─────────────────────────────────────────────

overall_mttr = round(df['Resolution_Time_mins'].mean(), 1)

print("\n──── OVERALL MTTR ────")
print(f"MTTR: {overall_mttr} mins")
print(f"MTTR: {round(overall_mttr / 60, 2)} hours")

# Priority-wise MTTR
mttr_by_priority = df.groupby('Priority')['Resolution_Time_mins'].agg(
    Total_Incidents='count',
    Avg_MTTR_mins='mean'
).reset_index()

mttr_by_priority['Avg_MTTR_mins'] = mttr_by_priority['Avg_MTTR_mins'].round(1)
mttr_by_priority['Avg_MTTR_hours'] = (
    mttr_by_priority['Avg_MTTR_mins'] / 60
).round(2)

print("\n──── MTTR BY PRIORITY ────")
print(mttr_by_priority.to_string(index=False))

# System-wise MTTR
mttr_by_system = df.groupby('Systems')['Resolution_Time_mins'].agg(
    Total_Incidents='count',
    Avg_MTTR_mins='mean',
    Max_MTTR_mins='max',
    Min_MTTR_mins='min'
).reset_index()

mttr_by_system['Avg_MTTR_mins'] = (
    mttr_by_system['Avg_MTTR_mins'].round(1)
)

mttr_by_system['Avg_MTTR_hours'] = (
    mttr_by_system['Avg_MTTR_mins'] / 60
).round(2)

mttr_by_system = mttr_by_system.sort_values(
    by='Avg_MTTR_mins',
    ascending=False
)

print("\n──── MTTR BY SYSTEM ────")
print(mttr_by_system.to_string(index=False))

# ─────────────────────────────────────────────
# MTBF (Mean Time Between Failures)
# ─────────────────────────────────────────────

df['Start_Time'] = pd.to_datetime(df['Start_Time'])

df_sorted = df.sort_values('Start_Time')

df_sorted['Previous_Start_Time'] = (
    df_sorted['Start_Time'].shift(1)
)

df_sorted['Gap_Days'] = (
    df_sorted['Start_Time'] -
    df_sorted['Previous_Start_Time']
).dt.total_seconds() / (60 * 60 * 24)

overall_mtbf = round(df_sorted['Gap_Days'].mean(), 2)

print("\n──── OVERALL MTBF ────")
print(f"MTBF: {overall_mtbf} days")

# ─────────────────────────────────────────────
# Reliability Calculation
# ─────────────────────────────────────────────

total_hours = 24 * 365

total_downtime_hours = (
    df['Resolution_Time_mins'].sum() / 60
)

reliability = round(
    (1 - (total_downtime_hours / total_hours)) * 100,
    3
)

print("\n──── SYSTEM RELIABILITY ────")
print(f"Reliability: {reliability}%")

# ─────────────────────────────────────────────
# Export Results to Excel
# ─────────────────────────────────────────────

with pd.ExcelWriter('Incident_Analytics_Report.xlsx') as writer:

    mttr_by_priority.to_excel(
        writer,
        sheet_name='MTTR_by_Priority',
        index=False
    )

    mttr_by_system.to_excel(
        writer,
        sheet_name='MTTR_by_System',
        index=False
    )

print("\nExcel report saved successfully.")