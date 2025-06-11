import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from scipy.stats import permutation_test
import matplotlib.patches as mpatches


# 辅助函数：将p值转换为星号标记
def p_to_star(p):
    if p < 0.001:
        return '***'
    elif p < 0.01:
        return '**'
    elif p < 0.05:
        return '*'
    else:
        return 'ns'


# 处理单个CSV文件的函数
def process_csv(file_path, reference_values, y_label, fig_title_prefix=''):
    # 读取CSV文件，只包含三列：standard, advanced, delayed
    df = pd.read_csv(file_path)[['standard', 'advanced', 'delayed']]
    col_names = df.columns.tolist()

    # 创建图形
    fig, axes = plt.subplots(2, 1, figsize=(10, 12))
    plt.subplots_adjust(hspace=0.4)

    # ======================
    # 第一张图：单样本t检验和小提琴图
    # ======================
    ax1 = axes[0]
    plt.sca(ax1)

    # 绘制小提琴图和散点图
    sns.violinplot(data=df, palette="Set3", inner=None, cut=0)
    sns.stripplot(data=df, color="black", alpha=0.6, size=5, jitter=True)

    # 执行单样本t检验并添加显著性标记
    for i, col in enumerate(col_names):
        t_stat, p_val = stats.ttest_1samp(df[col].dropna(), reference_values[i])
        star = p_to_star(p_val)
        # 放置在最高点上方
        y_pos = df[col].max() * 1.05
        ax1.text(i, y_pos, star, ha='center', va='bottom', fontsize=14, fontweight='bold')
        ax1.text(i, y_pos * 0.93, f"(p={p_val:.4f})", ha='center', va='top', fontsize=10)

    ax1.set_title(f'{fig_title_prefix}单样本t检验（参考值: {reference_values}）')
    ax1.set_ylabel(y_label)

    # ======================
    # 第二张图：两两置换检验
    # ======================
    ax2 = axes[1]
    plt.sca(ax2)

    # 绘制小提琴图
    sns.violinplot(data=df, palette="Set3", inner=None, cut=0)

    # 执行两两置换检验
    comparisons = []
    pairs = [(0, 1), (0, 2), (1, 2)]  # 对应列索引：(standard-adv, standard-del, adv-del)

    for pair in pairs:
        i, j = pair
        col1 = df[col_names[i]].dropna()
        col2 = df[col_names[j]].dropna()

        def statistic(x, y):
            return np.mean(x) - np.mean(y)

        res = permutation_test((col1, col2), statistic,
                                       n_resamples=10000)

        comparisons.append({
            'pair': pair,
            'p_value': res.pvalue,
            'star': p_to_star(res.pvalue)
        })

    # 添加显著性标记和连接线
    y_max = df.max().max()
    y_offset = y_max * 0.1
    line_height = 1.2 * y_max

    for comp in comparisons:
        i, j = comp['pair']
        # 画连接线
        ax2.plot([i, j], [line_height, line_height], color='black', lw=1.5)
        # 添加星号标记
        ax2.text((i + j) / 2, line_height * 1.05, comp['star'],
                 ha='center', va='bottom', fontsize=14, fontweight='bold')
        # 添加p值
        ax2.text((i + j) / 2, line_height * 0.95, f"(p={comp['p_value']:.4f})",
                 ha='center', va='top', fontsize=10)
        line_height += y_offset

    ax2.set_title(f'{fig_title_prefix}置换检验两两比较（独立样本）')
    ax2.set_ylabel(y_label)

    return fig, df


# 主程序
if __name__ == "__main__":
    # 设置参考值 - 这些值需要根据您的实验设计进行修改
    # 每个列表的三个值分别对应：standard, advanced, delayed
    time_ref_vals = [1080, 780, 1380]  # 时间感知的参考值（示例）
    dist_ref_vals = [2750, 2000, 3500]  # 距离感知的参考值（示例）

    # 处理第一个CSV文件（时间感知）
    file1 = "Study1_PerceivedTime.csv"  # 修改为实际文件路径
    fig1, time_df = process_csv(file1, time_ref_vals, "perceived_time (s)", "时间感知 - ")

    # 处理第二个CSV文件（距离感知）
    file2 = "Study2_PerceivedDistance.csv"  # 修改为实际文件路径
    fig2, dist_df = process_csv(file2, dist_ref_vals, "perceived_distance (m)", "距离感知 - ")

    # 保存结果到Excel文件
    # with pd.ExcelWriter('analysis_results.xlsx') as writer:
    #     time_df.describe().to_excel(writer, sheet_name='时间感知统计')
    #     dist_df.describe().to_excel(writer, sheet_name='距离感知统计')

    # 显示图形
    plt.tight_layout()
    plt.show()