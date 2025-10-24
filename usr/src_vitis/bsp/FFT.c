#include "FFT.h"
#include "main.h"
#include "timer.h"
#include <stdio.h>
//必须加这个空函数，不然编译会报错 undefined reference to `_gettimeofday'
void _gettimeofday(void)
{};
u32 FFT_time;
//FFT测试函数
void FFT_test()
{
    // 生成单精度正弦波
    float wave[FFT_POINTS];
    for (int i = 0; i < FFT_POINTS; i++) {
        float t = (float)i / SAMPLE_RATE;
        wave[i] = sinf(2 * M_PI * SIGNAL_FREQ * t);
    }
    // 分配内存（使用FFTW推荐的内存分配方式）
    float *signal = fftwf_alloc_real(FFT_POINTS);
    fftwf_complex *spectrum = fftwf_alloc_complex(FFT_POINTS/2 + 1);
    // 创建单精度FFTW计划
    fftwf_plan plan = fftwf_plan_dft_r2c_1d(FFT_POINTS, signal, spectrum, FFTW_MEASURE);
    // 执行FFT变换
    FFT_time=Get_time_value();
    for(int i=0;i<10;i++)
    {
        for(int j=0;j<FFT_POINTS;j++)
        {
            signal[j]=wave[j];
        }
        fftwf_execute(plan);
    }
    FFT_time=Get_time_value()-FFT_time;
    printf("执行10次%d点FFT运算耗时%dms\n",FFT_POINTS,FFT_time);
    // p = fftwf_plan_dft_1d(FFT_POINTS, in_cplx, out_cplx, FFTW_FORWARD, FFTW_ESTIMATE);

    // // 计算并打印功率谱
    // float freq_domain_power = 0.0f;
    // printf("频率(Hz)\t功率\n");
    // for (int k = 0; k < FFT_POINTS/2 + 1; k++) {
    //     // 计算频率值
    //     float freq = (float)k * SAMPLE_RATE / FFT_POINTS;
        
    //     // 计算复数模值的平方（使用单精度运算）
    //     float power = spectrum[k][0] * spectrum[k][0] + 
    //                  spectrum[k][1] * spectrum[k][1];
        
    //     // 双边谱转单边谱处理
    //     if(k>0 && k<FFT_POINTS/2) power *= 2.0f;
    //     // power /= (FFT_POINTS * FFT_POINTS);
    //     power /= (FFT_POINTS);
    //     freq_domain_power += power;
    //     printf("%.2f\t\t%.6f\n", freq, (double)power);
    // }
    // // 计算时域信号功率
    // float time_domain_power = 0.0f;
    // for(int i=0; i<FFT_POINTS; i++) {
    //     time_domain_power += signal[i] * signal[i];
    // }
    // printf("时域总功率: %.6f\n", time_domain_power);
    // printf("频域总功率: %.6f\n", freq_domain_power);
    // 释放资源
    fftwf_destroy_plan(plan);
    fftwf_free(signal);
    fftwf_free(spectrum);
}
