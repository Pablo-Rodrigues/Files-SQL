SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
CachedPlans
(
XMLPLAN,
EstimatedCost,
EstimatedIO,
EstimatedCPU,
EstimatedRows,
QueryText,
StatementSubTreeCost,
QueryPlan
)
AS
(
SELECT top 100
RelOp.op.query(N'.') AS XMLPLAN,
RelOp.op.value(N'@EstimatedTotalSubtreeCost ', N'float') AS EstimatedCost,
RelOp.op.value(N'@EstimateIO', N'float') AS EstimatedIO,
RelOp.op.value(N'@EstimateCPU', N'float') AS EstimatedCPU,
RelOp.op.value(N'@EstimateRows', N'float') AS EstimatedRows,
RelOp.op.value(N'@StatementSubTreeCost', N'VARCHAR(128)') AS StatementSubTreeCost,
st.TEXT AS QueryText,
qp.query_plan AS QueryPlan
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY qp.query_plan.nodes(N'//RelOp') RelOp (op)
WHERE RelOp.op.query(N'.').exist('//RelOp[@PhysicalOp="Parallelism"]') = 1
ORDER BY EstimatedIO desc
)
SELECT TOP 100
XMLPLAN,
QueryText,
QueryPlan,
StatementSubTreeCost,
EstimatedCost,
EstimatedIO,
EstimatedCPU,
EstimatedRows
FROM CachedPlans

