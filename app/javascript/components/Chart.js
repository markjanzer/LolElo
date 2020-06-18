import React, { useEffect, useState } from "react";
import styles from "./Chart.module.css";
import ax from "packs/axios";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ReferenceLine,
} from "recharts";

export default function Charts({ chartData }) {
  const lineChartData = chartData.data;
  const teamData = chartData.teams;
  const gameData = chartData.games;
  console.log(gameData);

  function customToolTip(props) {
    return (
      <div className={styles.toolTip}>
        <div className={styles.toolTipTitle}>{props.label}</div>
        <ul className={styles.games}>
          {gameData
            .filter((d) => d.date == props.label)
            .map((datum) => {
              return renderGame(datum);
            })}
        </ul>
      </div>
    );
  }

  function renderEloChange(changeAmount) {
    let changeStyle, formattedAmount;
    if (changeAmount < 0) {
      changeStyle = styles.negativeChange;
      formattedAmount = changeAmount.toString();
    } else {
      changeStyle = styles.positiveChange;
      formattedAmount = "+ " + changeAmount.toString();
    }

    return <div className={changeStyle}>{formattedAmount}</div>;
  }

  function renderGame(game) {
    let score;
    if (game.victor == 1) {
      score = "1 - 0";
    } else {
      score = "0 - 1";
    }

    return (
      <li className={styles.game}>
        <div className={styles.opponent}>
          <div
            className={styles.opponentAcronym}
            style={{ borderBottom: `2px solid ${game.opponent_1_color}` }}
          >
            {game.opponent_1}
          </div>
          <div className={styles.opponentEloData}>
            <div className={styles.opponentElo}>{game.opponent_1_elo}</div>
            {renderEloChange(game.opponent_1_elo_change)}
          </div>
        </div>
        <div className={styles.gameResult}>{score}</div>
        <div className={styles.opponent}>
          <div
            className={styles.opponentAcronym}
            style={{ borderBottom: `2px solid ${game.opponent_2_color}` }}
          >
            {game.opponent_2}
          </div>
          <div className={styles.opponentEloData}>
            <div className={styles.opponentElo}>{game.opponent_2_elo}</div>
            {renderEloChange(game.opponent_2_elo_change)}
          </div>
        </div>
      </li>
    );
  }

  return (
    <>
      <LineChart width={1200} height={800} data={lineChartData}>
        <CartesianGrid />
        <XAxis dataKey="name" padding={{ left: 30, right: 30 }} />
        <YAxis type="number" domain={["dataMin - 50", "dataMax + 50"]} />
        <Legend />
        <Tooltip content={customToolTip} />
        {teamData.map((team) => {
          return (
            <Line
              key={team.id}
              type="monotone"
              strokeWidth={2}
              dataKey={team.acronym}
              stroke={team.color}
            />
          );
        })}
      </LineChart>
    </>
  );
}
