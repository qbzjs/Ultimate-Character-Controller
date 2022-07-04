//状态机接口
public interface IState
{

    //进入
    void OnEnter();
    //执行
    void OnUpdate();
    //退出
    void OnExit();
}
