public with sharing class ProcessFormulaShareQueueable implements Queueable {

	private FormulaShareService.FormulaShareWrapper fsWrapper;

	public ProcessFormulaShareQueueable(FormulaShareService.FormulaShareWrapper fsWrapper) {
		this.fsWrapper = fsWrapper;
	}

	public void execute(QueueableContext context) {
		FormulaShareService.processFormulaShares(fsWrapper);
	}

}