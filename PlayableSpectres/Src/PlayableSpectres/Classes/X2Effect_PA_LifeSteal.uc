class X2Effect_PA_LifeSteal extends X2Effect;

var float PA_LifeAmountMultiplier;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Ability Ability;
	local XComGameState_Unit TargetUnit, OldTargetUnit, SourceUnit;
	local int SourceObjectID;
	local XComGameStateHistory History;
	local int LifeAmount;

	History = `XCOMHISTORY;

	Ability = XComGameState_Ability(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if( Ability == none )
	{
		Ability = XComGameState_Ability(History.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	}

	TargetUnit = XComGameState_Unit(kNewTargetState);
	if( (Ability != none) && (TargetUnit != none) )
	{
		SourceObjectID = ApplyEffectParameters.SourceStateObjectRef.ObjectID;
		SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(SourceObjectID));
		OldTargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(TargetUnit.ObjectID));
		
		if( (SourceUnit != none) && (OldTargetUnit != none) )
		{
			LifeAmount = (OldTargetUnit.GetCurrentStat(eStat_HP) - TargetUnit.GetCurrentStat(eStat_HP));

			if( PA_LifeAmountMultiplier != 0.0f )
			{
				LifeAmount = LifeAmount * PA_LifeAmountMultiplier;
			}

			SourceUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SourceObjectID));
			SourceUnit.ModifyCurrentStat(eStat_HP, LifeAmount);
		}
	}
}

simulated function AddX2ActionsForVisualizationSource(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit OldUnit, NewUnit;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local int Healed;

	if (EffectApplyResult != 'AA_Success')
		return;

	OldUnit = XComGameState_Unit(ActionMetadata.StateObject_OldState);
	NewUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);

	Healed = NewUnit.GetCurrentStat(eStat_HP) - OldUnit.GetCurrentStat(eStat_HP);
	
	if( Healed > 0 )
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "+" $ Healed, '', eColor_Good);
	}
}