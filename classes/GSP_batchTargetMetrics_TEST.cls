@isTest
private class GSP_batchTargetMetrics_TEST
{
	@isTest(seeAllData=true)
	private static void test_GSP_batchTargetMetrics()
	{		
		GSP_batchTargetMetrics batch = new GSP_batchTargetMetrics('OPPORTUNITY');
		Database.executeBatch(batch, 1);
	}
}