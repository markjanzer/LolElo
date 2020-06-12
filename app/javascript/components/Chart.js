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

export default function Charts() {
  useEffect(() => {
    ax.get("/chart_data").then((result) => {
      console.log(result.data);
      setChartData(result.data);
    });
  }, []);

  const [chartData, setChartData] = useState({ data: [], teams: [] });

  console.log(chartData);

  const lineChartData = chartData.data;
  const teamData = chartData.teams;
  console.log(chartData);

  return (
    <LineChart width={1200} height={800} data={lineChartData}>
      <CartesianGrid strokeDasharray="3 3" />
      <XAxis dataKey="name" padding={{ left: 30, right: 30 }} />
      <YAxis />
      <Tooltip />
      <Legend />
      {teamData.map((team) => {
        return (
          <Line
            key={team.id}
            type="monotone"
            dataKey={team.acronym}
            stroke="#8884d8"
          />
        );
      })}
    </LineChart>
  );
}
