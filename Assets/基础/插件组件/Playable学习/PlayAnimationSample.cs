
using UnityEngine;

using UnityEngine.Playables;

using UnityEngine.Animations;

[RequireComponent(typeof(Animator))]

public class PlayAnimationUtilitiesSample : MonoBehaviour

{

    public AnimationClip clip;

    PlayableGraph playableGraph;

    void Start()

    {

        AnimationPlayableUtilities.PlayClip(GetComponent<Animator>(), clip, out playableGraph);

    }

    void OnDisable()

    {

        // 销毁该图创建的所有可播放项和输出。

        playableGraph.Destroy();

    }

}