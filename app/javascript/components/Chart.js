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
  // useEffect(() => {
  //   ax.get("/chart_data").then((result) => {
  //     console.log(result.data);
  //     setChartData(result.data);
  //   });
  // }, []);

  // const [chartData, setChartData] = useState({ data: [], teams: [] });

  const lineChartData = chartData.data;
  const teamData = chartData.teams;
  const gameData = chartData.games;
  console.log(gameData);

  function showToolTip() {}

  function hideToolTip() {}

  function customToolTip(props) {
    return (
      <div className={styles.customToolTip}>
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
          <div className={styles.opponentAcronym}>{game.opponent_1}</div>
          <div className={styles.opponentElo}>{game.opponent_1_elo}</div>
          <div className={styles.opponentEloChange}>
            {game.opponent_1_elo_change}
          </div>
        </div>
        <div className={styles.gameResult}>{score}</div>
        <div className={styles.opponent}>
          <div className={styles.opponentAcronym}>{game.opponent_2}</div>
          <div className={styles.opponentElo}>{game.opponent_2_elo}</div>
          <div className={styles.opponentEloChange}>
            {game.opponent_2_elo_change}
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
              activeDot={{
                onMouseOver: () => console.log("onMouseOver"),
                onMouseLeave: () => console.log("onMouseLeave"),
              }}
            />
          );
        })}
      </LineChart>
      <ul className={styles.games}>{renderGame(gameData[0])}</ul>
    </>
  );
}
