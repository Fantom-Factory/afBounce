using afButter

class BounceButterDish : ButterDish, SizzleDish {
	override Butter butter
	new make(Butter butter) { this.butter = butter }	
}
