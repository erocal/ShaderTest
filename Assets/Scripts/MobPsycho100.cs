using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MobPsycho100 : MonoBehaviour
{
    #region -- 戈方把σ跋 --

    [SerializeField] private CustomImage MobPsycho100_Hundreds;
    [SerializeField] private CustomImage MobPsycho100_Tens;
    [SerializeField] private CustomImage MobPsycho100_Digits;
    [SerializeField] private CustomImage MobPsycho100_Percentage;

    #endregion

    #region -- 跑计把σ跋 --

    private float timer = 0f;
    private float interval = 0.5f;
    int mobPsycho100Count = 0;

    #endregion

    #region -- ﹍て/笲 --

    void FixedUpdate()
    {
        ChangeInterval();

        MobPsycho100Count();

        if (CheckIsHundred())
        {
            MobPsycho100_Hundreds.material.SetFloat("_Alpha", 1);
            MobPsycho100_Tens.material.SetColor("_Color", Color.red);
            MobPsycho100_Digits.material.SetColor("_Color", Color.red);
            MobPsycho100_Percentage.material.SetColor("_Color", Color.red);
        }
        else
        {
            MobPsycho100_Hundreds.material.SetFloat("_Alpha", 0);
            MobPsycho100_Tens.material.SetColor("_Color", Color.white);
            MobPsycho100_Digits.material.SetColor("_Color", Color.white);
            MobPsycho100_Percentage.material.SetColor("_Color", Color.white);
        }

        SetMobPsycho100();
    }

    #endregion

    private void ChangeInterval()
    {
        if (mobPsycho100Count < 90)
            interval = 0.1f;
        else if (mobPsycho100Count < 96)
            interval = 0.5f;
        else if (mobPsycho100Count < 99)
            interval = 1f;
        else if (mobPsycho100Count < 100)
            interval = 5f;
        else
            interval = 10f;
    }

    private void MobPsycho100Count()
    {
        timer += Time.fixedDeltaTime;

        if (timer >= interval)
        {

            mobPsycho100Count++;
            mobPsycho100Count %= 101;

            timer = 0f;
        }
    }

    private bool CheckIsHundred()
    {
        return mobPsycho100Count == 100;
    }

    private void SetMobPsycho100()
    {

        MobPsycho100_Tens.material.SetInt("_CurSequenceId", mobPsycho100Count / 10 % 10);
        MobPsycho100_Digits.material.SetInt("_CurSequenceId", mobPsycho100Count % 10);

    }
}
