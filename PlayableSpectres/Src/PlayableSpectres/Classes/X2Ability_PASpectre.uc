class X2Ability_PASpectre extends X2Ability config(GameData_PASpectre_Ability);

var localized string WillLostFriendlyName, WillLossString;
var localized string ShadowbindUnconsciousFriendlyName;

var name PA_Spectre_ShadownBoundLinkName;

var config bool PASpectre_DoesHorror_ExcludeFriendlyToSource;
var config bool PASpectre_DoesHorror_ExcludeRobotic;
var config bool PASpectre_DoesHorror_FailOnNonUnits;
var config bool PASpectre_DoesHorror_ExcludeAlien;
var config bool PASpectre_DoesHorror_IgnoreArmor;
var config bool PASpectre_DoesHorror_ConsumeAllPoints;

var config int PASpectre_Horror_ActionPointCost;
var config int PASpectre_Horror_Cooldown;
var config int PASpectre_Horror_ToHitBaseChance;
var config int PA_Spectre_ShadownBound_ActionPoints;
var config int PA_Spectre_ShadownBound_Cooldown;

var privatewrite name SoulStealEventName;
var privatewrite name SoulStealUnitValue;

var name SireZombieLinkName;


static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreatePA_Horror());

	return Templates;
}

static function X2AbilityTemplate CreatePA_Horror()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown Cooldown;
	local X2AbilityToHitCalc_RollStat RollStat;
	local X2Condition_UnitProperty UnitPropertyCondition;
	local X2Condition_UnitImmunities UnitImmunityCondition;
	local X2Effect_ApplyWeaponDamage HorrorDamageEffect;
	local X2Effect_PerkAttachForFX WillLossEffect;
	local X2Effect_SoulSteal                StealEffect;
	local array<name> SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'PA_Horror');

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_horror";
	Template.Hostility = eHostility_Offensive;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.PASpectre_Horror_ActionPointCost;
	ActionPointCost.bConsumeAllPoints = default.PASpectre_DoesHorror_ConsumeAllPoints;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.PASpectre_Horror_Cooldown;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// This will be a stat contest
	RollStat = new class'X2AbilityToHitCalc_RollStat';
	RollStat.StatToRoll = eStat_Will;
	RollStat.BaseChance = default.PASpectre_Horror_ToHitBaseChance;
	Template.AbilityToHitCalc = RollStat;

	// Shooter conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Target conditions
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = default.PASpectre_DoesHorror_ExcludeFriendlyToSource;
	UnitPropertyCondition.ExcludeRobotic = default.PASpectre_DoesHorror_ExcludeRobotic;
	UnitPropertyCondition.FailOnNonUnits = default.PASpectre_DoesHorror_FailOnNonUnits;
	UnitPropertyCondition.ExcludeAlien = default.PASpectre_DoesHorror_ExcludeAlien;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	UnitImmunityCondition = new class'X2Condition_UnitImmunities';
	UnitImmunityCondition.AddExcludeDamageType('Mental');
	UnitImmunityCondition.bOnlyOnCharacterTemplate = true;
	Template.AbilityTargetConditions.AddItem(UnitImmunityCondition);

	// Target Effects
	WillLossEffect = new class'X2Effect_PerkAttachForFX';
	WillLossEffect.BuildPersistentEffect(1, false, false);
	WillLossEffect.DuplicateResponse = eDupe_Allow;
	WillLossEffect.EffectName = 'HorrorWillLossEffect';
	Template.AddTargetEffect(WillLossEffect);

	HorrorDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	HorrorDamageEffect.bIgnoreBaseDamage = true;
	HorrorDamageEffect.DamageTag = 'Horror';
	HorrorDamageEffect.bIgnoreArmor = default.PASpectre_DoesHorror_IgnoreArmor;
	Template.AddTargetEffect(HorrorDamageEffect);

	StealEffect = new class'X2Effect_SoulSteal';
	StealEffect.UnitValueToRead = default.SoulStealUnitValue;
	Template.AddShooterEffect(StealEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bShowActivation = true;

	Template.CinescriptCameraType = "Spectre_Horror";

	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	Template.PostActivationEvents.AddItem('PA_HorrorActivated');
//BEGIN AUTOGENERATED CODE: Template Overrides 'Horror'
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.ActionFireClass = class'XComGame.X2Action_Fire_Horror';
	Template.CustomFireAnim = 'HL_Horror_StartA';
//END AUTOGENERATED CODE: Template Overrides 'Horror'

	return Template;
}

DefaultProperties
{
	SoulStealEventName="SoulStealTriggered"
	SoulStealUnitValue="SoulStealAmount"
}