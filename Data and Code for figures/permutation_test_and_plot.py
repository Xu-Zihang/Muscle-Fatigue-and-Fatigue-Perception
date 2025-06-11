import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import permutation_test


def permutation_test_and_plot(csv_file, y_label):
    """
    读取CSV文件数据，执行置换检验并绘制小提琴图

    参数:
        csv_file (str): CSV文件路径
        y_label (str): 纵轴标题

    返回:
        dict: 包含显著性检验结果和统计量的字典
    """
    # 1. 读取CSV文件的前三列数据
    try:
        df = pd.read_csv(csv_file, usecols=[0, 1, 2])
        df.columns = ['Standard', 'Advanced', 'Delayed']
        print(f"成功读取数据，三列名称已重命名为: {df.columns.tolist()}")
    except Exception as e:
        print(f"读取CSV文件时出错: {e}")
        return None

    # 2. 准备数据
    # 将数据从宽格式转换为长格式
    data_long = df.melt(var_name='Group', value_name='Value')

    # 3. 执行两两置换检验
    groups = ['Standard', 'Advanced', 'Delayed']
    pairs = [(0, 1), (0, 2), (1, 2)]  # 比较组合索引
    significance_results = {}

    print("\n执行置换检验...")
    for i, j in pairs:
        group1 = df[groups[i]].dropna().values
        group2 = df[groups[j]].dropna().values

        # 定义计算均值差的统计量函数
        def statistic(x, y):
            return np.mean(x) - np.mean(y)

        # 执行置换检验
        res = permutation_test((group1, group2), statistic, n_resamples=10000,
                               alternative='two-sided', random_state=42)

        # 存储结果
        key = f"{groups[i]} vs {groups[j]}"
        significance_results[key] = {
            'p_value': res.pvalue,
            'mean_diff': np.mean(group1) - np.mean(group2),
            'effect_size': abs(np.mean(group1) - np.mean(group2)) /
                           np.sqrt((np.var(group1) + np.var(group2)) / 2)
        }

        print(
            f"  {key}: p = {res.pvalue:.4f}, 均值差 = {np.mean(group1) - np.mean(group2):.2f}, Cohen's d = {significance_results[key]['effect_size']:.2f}")

    # 4. 准备显著性标注位置
    # 计算每组最大值作为标注位置
    max_values = [df[col].max() for col in df.columns]
    max_global = max(max_values)
    height_factor = 1.08

    # 创建标注位置坐标
    annotation_data = []
    for i, pair in enumerate(pairs):
        # 每对比较的x坐标位置
        x1, x2 = pair
        # 在最高点上方的位置
        y = max_global * (height_factor + i * 0.1)
        annotation_data.append((x1 + 1, x2 + 1, y, significance_results[f"{groups[x1]} vs {groups[x2]}"]['p_value']))

    # 5. 创建显著性标记的星号表示
    def get_stars(p):
        if p < 0.001:
            return '***'
        elif p < 0.01:
            return '**'
        elif p < 0.05:
            return '*'
        else:
            return 'n.s.'  # 不显著

    # 6. 绘制小提琴图
    plt.figure(figsize=(10, 7))
    ax = sns.violinplot(data=data_long, x='Group', y='Value', palette='Set2',
                        inner='quartile', cut=0)

    # 添加数据点
    sns.stripplot(data=data_long, x='Group', y='Value', color='black',
                  alpha=0.4, jitter=0.2, size=4, ax=ax)

    # 设置标题和标签
    plt.title('组间比较小提琴图', fontsize=14, fontweight='bold')
    plt.xlabel('')
    plt.ylabel(y_label, fontsize=12)
    plt.ylim(bottom=0, top=max_global * 1.4)  # 留出空间标注显著性

    # 7. 添加显著性标注
    for x1, x2, y, p in annotation_data:
        # 添加水平线
        plt.plot([x1, x1, x2, x2], [y, y + max_global * 0.02, y + max_global * 0.02, y],
                 lw=1, c='black')

        # 添加星号标记
        stars = get_stars(p)
        plt.text((x1 + x2) * 0.5, y + max_global * 0.03, stars,
                 ha='center', va='bottom', color='black', fontsize=14)

        # 在下方添加p值
        p_text = f"p={p:.3f}" if p >= 0.001 else "p<0.001"
        plt.text((x1 + x2) * 0.5, y - max_global * 0.03, p_text,
                 ha='center', va='top', color='blue', fontsize=10)

    # 8. 在图表下方添加统计摘要
    stats_text = ""
    for k, v in significance_results.items():
        stats_text += f"{k}: p={v['p_value']:.3f}, 均值差={v['mean_diff']:.2f} | "

    plt.figtext(0.5, 0.01, stats_text[:-2], ha="center",
                fontsize=10, bbox={"facecolor": "lightgray", "alpha": 0.3, "pad": 5})

    # 9. 显示并保存图表
    plt.tight_layout()
    plt.savefig(f'{y_label}_comparison_plot.png', dpi=300)
    plt.show()

    # 10. 返回统计结果
    return {
        'data': df,
        'descriptive_stats': df.describe(),
        'significance_results': significance_results
    }