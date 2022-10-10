using System;
using UnityEditor;
using UnityEngine;

namespace FIMSpace.AnimationTools
{
    public partial class AnimationDesignerWindow : EditorWindow
    {

        ADClipSettings_Main _anim_MainSet;
        ADClipSettings_Elasticness _anim_elSet;
        ADClipSettings_Modificators _anim_modSet;
        ADClipSettings_IK _anim_ikSet;
        ADClipSettings_Springs _anim_springsSet;
        ADClipSettings_Morphing _anim_morphSet;


        //ADClipSettings_Main _clipSettings_Main;
        //ADClipSettings_Elasticness _clipSettings_Elasticness;
        //ADClipSettings_Modificators _clipSettings_Modificators;
        //ADClipSettings_IK _clipSettings_IK;
        //ADClipSettings_Springs _clipSettings_Springs;
        //ADClipSettings_Blending _clipSettings_Blending;


        public void ResetComponentsStates(bool reInitialize)
        {
            CheckComponentsInitialization(reInitialize);

            for (int i = 0; i < Limbs.Count; i++)
                Limbs[i].ResetLimbComponentsState();

            _anim_MainSet.ResetState(S);
            _anim_modSet.ResetStates();
            _anim_ikSet.ResetState();
        }

        bool _latestWasMorphing = false;
        void UpdateSimulationAfterAnimators(ADRootMotionBakeHelper rootBaker)
        {

            #region Morphing bake and restore

            _latestWasMorphing = false;

            if (_anim_MainSet.TurnOnMorphs)
                for (int i = 0; i < _anim_morphSet.Morphs.Count; i++)
                {
                    var morph = _anim_morphSet.Morphs[i];
                    if (morph.Enabled == false) continue;
                    _latestWasMorphing = true;
                    morph.CaptureMorph(S, _anim_MainSet);
                }

            if (_latestWasMorphing)
            {
                SampleCurrentAnimation(latestAutoElapse);
            }

            #endregion


            if (rootBaker != null)
            {
                rootBaker.PostAnimator();
            }


            #region Morphs Apply

            if (_latestWasMorphing)
            {
                for (int i = 0; i < _anim_morphSet.Morphs.Count; i++)
                {
                    var morph = _anim_morphSet.Morphs[i];
                    if (morph.Enabled == false) continue;
                    if (morph.UpdateOrder != ADClipSettings_Morphing.MorphingSet.EOrder.InheritElasticness) continue;
                    morph.ApplyMorph(animationProgress, S);
                }
            }

            #endregion


            _anim_modSet.PreLateUpdateModificators(deltaTime);
            _anim_modSet.BeforeLateUpdateModificators(deltaTime, animationProgress, S, _anim_MainSet);

            if (rootBaker != null)
            {
                rootBaker.PostRootMotion();
                _anim_MainSet.LatestInternalRootMotionOffset = rootBaker.latestRootMotionPos;
            }
            else
            {
                _anim_MainSet.LatestInternalRootMotionOffset = ADRootMotionBakeHelper.RootModsOffsetAccumulation;
            }

            if (_anim_MainSet.TurnOnIK)
            {
                var limbsExecutionListIK = S.GetLimbsExecutionList(_anim_ikSet.LimbIKSetups);
                for (int i = 0; i < limbsExecutionListIK.Count; i++)
                    limbsExecutionListIK[i].IKCapture(_anim_ikSet.GetIKSettingsForLimb(limbsExecutionListIK[i], S));
            }

            _anim_MainSet.PreUpdateSimulation(S);

            _anim_modSet.PreElasticnessLateUpdateModificators(deltaTime, animationProgress, S, _anim_MainSet);

            if (_anim_MainSet.TurnOnElasticness)
                for (int i = 0; i < Limbs.Count; i++)
                    Limbs[i].ElasticnessPreLateUpdate(_anim_elSet);


            if (_anim_MainSet.TurnOnIK)
            {
                var limbsExecutionListIK = S.GetLimbsExecutionList(_anim_ikSet.LimbIKSetups);
                for (int i = 0; i < limbsExecutionListIK.Count; i++)
                    limbsExecutionListIK[i].IKUpdateSimulation(_anim_ikSet.GetIKSettingsForLimb(limbsExecutionListIK[i], S), deltaTime, animationProgress, 1f);
            }
        }


        void LateUpdateSimulation()
        {
            for (int i = 0; i < Limbs.Count; i++)
                Limbs[i].ComponentsBlendingLateUpdate(_anim_morphSet, deltaTime, animationProgress);


            if (_anim_MainSet.TurnOnElasticness)
            {
                for (int i = 0; i < Limbs.Count; i++)
                {
                    if (Limbs[i].ExecuteFirst == false) continue;
                    Limbs[i].ElasticnessComponentsLateUpdate(_anim_elSet, _anim_MainSet, deltaTime, animationProgress);
                }

                for (int i = 0; i < Limbs.Count; i++)
                {
                    if (Limbs[i].ExecuteFirst == true) continue;
                    Limbs[i].ElasticnessComponentsLateUpdate(_anim_elSet, _anim_MainSet, deltaTime, animationProgress);
                }
            }


            _anim_modSet.LateUpdateModificators(deltaTime, animationProgress, S, _anim_MainSet);


            _anim_MainSet.LateUpdateSimulation(deltaTime, deltaTime, animationProgress, S);



            if (_anim_MainSet.TurnOnIK)
            {
                var limbsExecutionListIK = S.GetLimbsExecutionList(_anim_ikSet.LimbIKSetups);
                for (int i = 0; i < limbsExecutionListIK.Count; i++)
                    limbsExecutionListIK[i].IKLateUpdateSimulation(_anim_ikSet.GetIKSettingsForLimb(limbsExecutionListIK[i], S), dt, animationProgress, 1f, _anim_MainSet);
            }

            _anim_modSet.LastLateUpdateModificators(deltaTime, animationProgress, S, _anim_MainSet);


            #region Morphs Apply

            if (_latestWasMorphing)
            {
                for (int i = 0; i < _anim_morphSet.Morphs.Count; i++)
                {
                    var morph = _anim_morphSet.Morphs[i];
                    if (morph.Enabled == false) continue;
                    if (morph.UpdateOrder != ADClipSettings_Morphing.MorphingSet.EOrder.OverrideModsAndIK) continue;
                    morph.ApplyMorph(animationProgress, S);
                }
            }

            #endregion


            _anim_MainSet.LateUpdateAfterAllSimulation();

        }


        internal void CheckComponentsInitialization(bool reInitialize)
        {
            bool hChanged = false;
            for (int i = 0; i < Limbs.Count; i++)
                if (Limbs[i].CheckIfHierarchyChanged()) hChanged = true;

            if (hChanged)
            {
                reInitialize = true;
                if (S) S._SetDirty();
            }

            _anim_MainSet = S.GetSetupForClip(S.MainSetupsForClips, TargetClip, _toSet_SetSwitchToHash);
            //_anim_MainSet = S.GetMainSetupForClip(TargetClip);
            _anim_MainSet.CheckForInitialization(S, reInitialize);

            for (int i = 0; i < Limbs.Count; i++) Limbs[i].RefreshLimb(S);

            _anim_elSet = S.GetSetupForClip(S.ElasticnessSetupsForClips, TargetClip, _toSet_SetSwitchToHash); //S.GetElasticnessSetupForClip(TargetClip);
            for (int i = 0; i < Limbs.Count; i++) Limbs[i].CheckLimbElasticnessComponentsInitialization(S, reInitialize);

            _anim_modSet = S.GetSetupForClip(S.ModificatorsSetupsForClips, TargetClip, _toSet_SetSwitchToHash); //_anim_modSet = S.GetModificatorsSetupForClip(TargetClip);
            _anim_modSet.CheckInitialization(S, reInitialize, _anim_MainSet);

            _anim_ikSet = S.GetSetupForClip(S.IKSetupsForClips, TargetClip, _toSet_SetSwitchToHash); //_anim_ikSet = S.GetIKSetupForClip(TargetClip);
            var limbsExecutionListIK = S.GetLimbsExecutionList(_anim_ikSet.LimbIKSetups);
            for (int i = 0; i < limbsExecutionListIK.Count; i++) limbsExecutionListIK[i].CheckForIKInitialization(S, _anim_ikSet.GetIKSettingsForLimb(limbsExecutionListIK[i], S), _anim_MainSet, animationProgress, dt, 1f, reInitialize);

            _anim_springsSet = S.GetSetupForClip(S.SpringSetupsForClips, TargetClip, _toSet_SetSwitchToHash); //_anim_springsSet = S.GetSpringSetupForClip(TargetClip);
            _anim_springsSet.CheckInitialization(S);

            _anim_morphSet = S.GetSetupForClip(S.MorphingSetupsForClips, TargetClip, _toSet_SetSwitchToHash); // _anim_blendSet = S.GetBlendingSetupForClip(TargetClip);
            for (int i = 0; i < Limbs.Count; i++) Limbs[i].CheckComponentsBlendingInitialization(reInitialize);
        }

        internal static Rect GetMenuDropdownRect(int width = 300)
        {
            return new Rect(Event.current.mousePosition + Vector2.left * 100, new Vector2(width, 340));
        }

    }
}