# ── Step 2: MTTR Calculate karo ──────────────────────────────────────────

# Overall MTTR
overall_mttr = round(df['resolution_mins'].mean(), 1)
print(f"\nOverall MTTR: {overall_mttr} mins = {round(overall_mttr/60, 2)} hours")

# Priority wise MTTR
mttr_by_priority = df.groupby('priority')['resolution_mins'].agg(
    Total_Incidents = 'count',
    Avg_MTTR_mins   = 'mean',
).reset_index()

mttr_by_priority['Avg_MTTR_mins']  = mttr_by_priority['Avg_MTTR_mins'].round(1)
mttr_by_priority['Avg_MTTR_hours'] = (mttr_by_priority['Avg_MTTR_mins'] / 60).round(2)

print("\n── MTTR by Priority ──")
print(mttr_by_priority.to_string(index=False))

# System wise MTTR
mttr_by_system = df.groupby('system_name')['resolution_mins'].agg(
    Total_Incidents = 'count',
    Avg_MTTR_mins   = 'mean',
    Max_MTTR_mins   = 'max',
    Min_MTTR_mins   = 'min'
).reset_index()

mttr_by_system['Avg_MTTR_mins']  = mttr_by_system['Avg_MTTR_mins'].round(1)
mttr_by_system['Avg_MTTR_hours'] = (mttr_by_system['Avg_MTTR_mins'] / 60).round(2)

mttr_by_system = mttr_by_system.sort_values('Avg_MTTR_mins', ascending=False)

print("\n── MTTR by System ──")
print(mttr_by_system.to_string(index=False))