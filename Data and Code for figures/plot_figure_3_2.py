import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import ttest_rel


def analyze_and_plot_fatigue_data(csv_filename):
    """
    分析主观疲劳数据并绘制图表

    参数:
    csv_filename (str): CSV文件路径
    output_image (str): 输出图像文件名(默认: 'fatigue_comparison.png')

    返回:
    tuple: (p_values, 绘图对象)
    """
    # 定义列名
    column_names = [
        'Standard_pre', 'Standard_post',
        'Advanced_pre', 'Advanced_post',
        'Delayed_pre', 'Delayed_post'
    ]

    # 读取CSV文件
    data = pd.read_csv(csv_filename, header=None, names=column_names)

    # 对各组执行配对t检验
    pairs = [
        ('Standard_pre', 'Standard_post'),
        ('Advanced_pre', 'Advanced_post'),
        ('Delayed_pre', 'Delayed_post')
    ]
    p_values = []

    for colA, colB in pairs:
        x = data[colA].dropna().values
        y = data[colB].dropna().values
        # 确保配对数据的长度一致
        min_len = min(len(x), len(y))
        x = x[:min_len]
        y = y[:min_len]
        # 执行配对t检验
        t_stat, p_val = ttest_rel(x, y)
        p_values.append(p_val)

    # 将数据转换为长格式用于绘图
    plot_data = pd.melt(data, value_vars=column_names, var_name='Condition', value_name='Value')
    # 定义每个条件的x位置
    positions = {
        'Standard_pre': 0, 'Standard_post': 1,
        'Advanced_pre': 2.5, 'Advanced_post': 3.5,
        'Delayed_pre': 5, 'Delayed_post': 6
    }
    plot_data['xpos'] = plot_data['Condition'].map(positions)

    # 创建图表
    plt.figure(figsize=(14, 8))
    ax = plt.gca()

    # 创建自定义位置的小提琴图 - 解决方法
    # 不再使用positions参数，而是通过设置x和hue来间接控制位置
    # 我们将所有点分组在一个"组"中，然后手动设置x轴位置
    plot_data['Group'] = plot_data['Condition'].apply(lambda x: x.split('_')[0])

    # 使用seaborn正确绘制小提琴图
    sns.violinplot(
        x='xpos', y='Value', data=plot_data,
        inner=None, color='lightgray', width=0.8,
        ax=ax
    )

    # 绘制数据点（带轻微抖动）
    np.random.seed(42)
    jitter = 0.15
    for condition, x_pos in positions.items():
        cond_data = plot_data[plot_data['Condition'] == condition]['Value']
        x_jitter = x_pos + np.random.uniform(-jitter, jitter, len(cond_data))
        plt.scatter(x_jitter, cond_data, s=30, alpha=0.6, edgecolor='black', zorder=10)

    # 添加组间连接线和显著性标记
    x_positions = [0.5, 3, 5.5]  # 各组中间位置
    max_vals = plot_data.groupby('xpos')['Value'].max()
    max_y = max_vals.max() + max_vals.max() * 0.15
    offset = max_vals.max() * 0.05  # 星号偏移量

    for (x_pos, p_val, group) in zip(x_positions, p_values, ['Standard', 'Advanced', 'Delayed']):
        # 绘制横线
        plt.hlines(y=max_y, xmin=x_pos - 0.5, xmax=x_pos + 0.5,
                   color='black', linewidth=1.5)

        # 添加组名
        plt.text(x_pos, max_y * 1.04, group,
                 ha='center', va='bottom', fontsize=12, fontweight='bold')

        # 添加星号标记
        if p_val < 0.001:
            sig_symbol = '***'
        elif p_val < 0.01:
            sig_symbol = '**'
        elif p_val < 0.05:
            sig_symbol = '*'
        else:
            sig_symbol = 'n.s.'

        plt.text(x_pos, max_y + offset, sig_symbol,
                 ha='center', va='bottom', fontsize=14, fontweight='bold')

    # 美化图表
    # 设置x轴标签
    ax.set_xticks(list(positions.values()))
    ax.set_xticklabels(
        ['Pre', 'Post', 'Pre', 'Post', 'Pre', 'Post'],
        fontsize=10
    )

    # 添加分隔线
    for pos in [1.75, 4.25]:
        plt.axvline(x=pos, color='gray', linestyle=':', alpha=0.5)

    # 设置轴标签
    plt.ylabel('Subjective Fatigue Level', fontsize=12)
    plt.xlabel('Intervention Conditions', fontsize=12)

    # 设置标题
    plt.title('Comparison of Subjective Fatigue Levels Pre- and Post-Intervention', fontsize=14)

    # 设置y轴范围
    min_val = min(plot_data['Value'])
    max_val = max(plot_data['Value'])
    plt.ylim(bottom=min_val - 0.1 * (max_val - min_val), top=max_y * 1.2)

    # 添加网格线
    plt.grid(axis='y', alpha=0.3)

    # 移除不必要的边界
    sns.despine()

    plt.tight_layout()


    # 打印p值结果
    print("\nPaired t-test results:")
    for (colA, colB), p_val in zip(pairs, p_values):
        print(f"  {colA} vs {colB}: p = {p_val:.10f}")

    plt.show()

    return p_values, plt