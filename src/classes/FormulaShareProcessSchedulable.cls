public class FormulaShareProcessSchedulable implements Schedulable {
	
	public void execute(SchedulableContext sc) {
		system.debug('Scheduled recalculation of FormulaShare rules begun');
		FormulaShareService.recalculateAll();
	}
}